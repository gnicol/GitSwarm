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

    define_method :start_checking do |component|
      component.gsub!(/GitLab/, 'GitSwarm')
      puts "Checking #{component.yellow} ..."
      puts ''
    end

    define_method :finished_checking do |component|
      component.gsub!(/GitLab/, 'GitSwarm')
      puts ''
      puts "Checking #{component.yellow} ... #{"Finished".green}"
      puts ''
    end
  end
end
