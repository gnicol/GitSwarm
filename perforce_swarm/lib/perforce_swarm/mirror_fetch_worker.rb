require 'rubygems'
require 'sidekiq'
require 'sidetiq'

module PerforceSwarm
  class MirrorFetchWorker
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    # check every 5 minutes
    recurrence { minutely(5) }

    def perform
      mirror_script =
          File.join(File.expand_path(Gitlab.config.gitlab_shell.path), 'perforce_swarm', 'bin', 'gitswarm-mirror')
      # for each project, perform a mirror fetch
      Project.all.each do |project|
        puts "Running mirror fetch against #{project.path_with_namespace}"
        system [mirror_script, 'fetch', '--min-outdated=300', project.path_with_namespace + '.git']
      end
    end
  end
end
