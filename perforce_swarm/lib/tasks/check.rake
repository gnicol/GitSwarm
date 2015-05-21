namespace :perforce_swarm do
  task :check_override do
    define_method :omnibus_gitlab? do
      !(Dir.pwd =~ %r{/embedded/service/gitlab-rails}).nil?
    end
  end
end

namespace :gitlab do
  desc 'GITSWARM | Check the configuration of GitSwarm and its environment'
  task check: ['perforce_swarm:check_override']
end
