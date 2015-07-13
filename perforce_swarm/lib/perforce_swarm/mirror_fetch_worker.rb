require 'rubygems'
require 'sidekiq'
require 'sidetiq'

module PerforceSwarm
  class MirrorFetchWorker
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    # check every 5 minutes
    # note this will only end up fetching every 10 minutes as we have a min-outdated of 5 minutes e.g.:
    # - Starting at 10:00:00 am
    # - fetch a (takes 6s) last_fetched = 10:00:06
    # - fetch b (takes 2s) last_fetched = 10:00:08
    #
    # - Re-run at 10:05:00 am
    # - fetch a skip (only 294 out of date)
    # - fetch b skip (only 292 out of date)
    #
    # - Re-run at 10:10:00 am
    # - fetches all the things as they are all sufficiently out of date
    recurrence { minutely(5) }

    def perform
      # locate the gitlab-shell mirror script we'll be calling
      shell_path    = File.expand_path(Gitlab.config.gitlab_shell.path)
      mirror_script = File.join(shell_path, 'perforce_swarm', 'bin', 'gitswarm-mirror')

      # for each project, perform a mirror fetch
      ::Project.all.each do |project|
        next unless PerforceSwarm::Repo.new(project.repository.path_to_repo).mirrored?

        system(mirror_script, 'fetch', '--min-outdated=300', project.path_with_namespace + '.git')
      end
    end
  end
end
