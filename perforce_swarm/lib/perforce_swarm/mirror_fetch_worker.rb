require 'rubygems'
require 'sidekiq'
require 'sidetiq'

module PerforceSwarm
  class MirrorFetchWorker
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    MAX_FETCH_SLOTS = 5

    # check every minute
    # @todo: add a comment block here describing what we're doing now
    recurrence { minutely(1) }

    def perform
      repo_stats = collect_stats

      # always ensure any stuck imports are marked as finished
      ensure_finished(repo_stats)

      # quit if there are no available slots, or no repos require mirroring
      available  = MAX_FETCH_SLOTS - active_count(repo_stats)
      repo_stats = remove_active(repo_stats)
      return unless available > 0 && repo_stats.length > 0

      # perform the fetch on remaining repos with the available slots
      do_fetch(repo_stats, available)
    end

    # returns the number of repos in repo_stats that are currently active/fetching
    def active_count(repo_stats)
      active = 0
      repo_stats.each do |stat|
        active += 1 if stat[:active]
      end
      active
    end

    # returns an array of repos that are current not active/fetching
    def remove_active(repo_stats)
      repo_stats.delete_if { |stat| stat[:active] }
    end

    # finishes up any repos that get stuck in the importing phase if the pull has wrapped up
    # normally a redis task cleans this up but a crash or other unexpected event could
    # leave it hung.
    def ensure_finished(repo_stats)
      repo_stats.each do |stats|
        project = stats[:project]
        next unless project.import_in_progress? && project.git_fusion_import? && stats[:last_fetched]

        project.import_finish
        project.save
      end
    end

    def do_fetch(repo_stats, slots)
      # bail if there are no available slots, or there is nothing to be mirrored
      task_count = [repo_stats.length, slots].min
      return unless task_count > 0

      # locate the gitlab-shell mirror script we'll be calling
      shell_path    = File.expand_path(Gitlab.config.gitlab_shell.path)
      mirror_script = File.join(shell_path, 'perforce_swarm', 'bin', 'gitswarm-mirror')

      # for each available slot, fork off a fetch task and background it immediately
      task_count.times do
        repo       = repo_stats.shift
        project    = repo[:project]
        import_job = fork do
          command = [mirror_script, 'fetch', '--min-outdated=60', project.path_with_namespace + '.git']
          exec Shellwords.shelljoin(command)
        end
        Process.detach(import_job)
      end
    end

    # returns an array of stats about the currently-mirrored repos, sorted by oldest to youngest
    # in terms of last fetched
    def collect_stats
      stats = []
      ::Project.all.each do |project|
        next unless PerforceSwarm::Repo.new(project.repository.path_to_repo).mirrored?

        repo_path = project.repository.path_to_repo
        stats.push(project: project,
                   last_fetched: PerforceSwarm::Mirror.last_fetched(repo_path) || 0,
                   active: PerforceSwarm::Mirror.fetch_locked?(repo_path)
                  )
      end

      # return sorted stats based on last_fetched time, oldest (smaller value) first
      stats.sort_by do |stat|
        stat[:last_fetched].to_i
      end
    end
  end
end
