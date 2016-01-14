require 'rubygems'
require 'sidekiq'

module PerforceSwarm
  class MirrorFetchWorker
    include Sidekiq::Worker

    # We are scheduled for every minute, so don't bother throwing in the retry queue
    sidekiq_options retry: false

    # We'll scan all the repos to:
    #  - clean up any hung git-fusion imports
    #  - fetch outdated repos to freshen them
    # Note we'll limit the number of active fetches to be ongoing via the
    # ['git_fusion']['fetch_worker']['max_fetch_slots'] config value.
    # Each fetch process seems to consume ~120M of RAM
    # If too many fetches are already active we won't fetch.
    # If there are free fetch slots, we'll background fetch starting with the most outdated repos.
    # We ensure we skip over repos that are already mid-fetch to avoid doubling up work.
    #
    # If we assume you have 20 repos that are fairly inactive in perforce (so generally we're pulling
    # down no or only small changes) this approach will keep you within ~10 minutes of up to date.
    def perform
      # bail completely if the feature isn't enabled
      config = PerforceSwarm::GitlabConfig.new
      return unless config.git_fusion.enabled?

      repo_stats = RepoStats.new

      # don't let any repos get stuck in the importing phase if the pull has wrapped up.
      # normally a redis task cleans this up but a crash or other unexpected event could
      # leave it hung.
      repo_stats.import_hung.each do |stat|
        stat[:project].import_finish
        stat[:project].save
      end

      # locate the gitlab-shell mirror script we'll be calling
      shell_path    = File.expand_path(Gitlab.config.gitlab_shell.path)
      mirror_script = File.join(shell_path, 'perforce_swarm', 'bin', 'gitswarm-mirror')

      # fetch the most outdated repos using the maximum available slots
      # if we have no slots, or no worthy repos, this is a no-op
      max_fetch_slots = config.git_fusion.fetch_worker['max_fetch_slots']
      limit           = max_fetch_slots - repo_stats.active_count
      repo_stats.fetch_worthy(config.git_fusion.fetch_worker['min_outdated'], limit).each do |stat|
        import_job = fork do
          exec Shellwords.shelljoin([mirror_script, 'fetch', stat[:project].path_with_namespace + '.git'])
        end
        Process.detach(import_job)
      end
    end

    class RepoStats
      attr_accessor :stats

      def initialize
        update
      end

      def update
        @stats = []
        ::Project.all.each do |project|
          next unless PerforceSwarm::Repo.new(project.repository.path_to_repo).mirrored?

          repo_path = project.repository.path_to_repo
          active    = PerforceSwarm::Mirror.fetch_locked?(repo_path) || PerforceSwarm::Mirror.write_locked?(repo_path)
          stats.push(project:       project,
                     last_fetched:  PerforceSwarm::Mirror.last_fetched(repo_path),
                     active:        active
                    )
        end

        # return sorted stats based on last_fetched time, oldest (smaller value) first
        stats.sort do |a, b|
          (a[:last_fetched] || 0).to_i <=> (b[:last_fetched] || 0).to_i
        end
      end

      # returns the number of mirrored repos that are actively being fetched
      def active_count
        stats.length - inactive_count
      end

      # returns the number of mirrored repos that are not actively being fetched
      def inactive_count
        inactive.length
      end

      # returns only stats representing mirrored repos that are not presently being fetched
      def inactive
        stats.select { |stat| !stat[:active] }
      end

      def fetch_worthy(min_outdated, limit = nil)
        limit ||= stats.length
        limit   = 0 if limit < 0
        inactive.select { |stat| !stat[:last_fetched] || stat[:last_fetched] < (Time.now - min_outdated) }.first(limit)
      end

      # returns only entries that represent git-fusion imports that are finished but marked as in progress
      def import_hung
        stats.select do |stat|
          stat[:project].import_in_progress? && stat[:project].git_fusion_mirrored? && stat[:last_fetched]
        end
      end
    end
  end
end
