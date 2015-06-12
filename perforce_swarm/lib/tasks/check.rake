module Kernel
  def puts (s)
    $stdout.puts(s.gsub(/gitlab/, 'gitswarm'))
  end
end

namespace :gitlab do
  desc 'GITSWARM | Check the configuration of GitSwarm and its environment'
  namespace :app do
    task check: ['perforce_swarm:check_override']
  end
end

namespace :perforce_swarm do
  task :check_override do
    define_method :omnibus_gitlab? do
      !(Dir.pwd =~ %r{/embedded/service/gitlab-rails}).nil?
    end
  end
end
