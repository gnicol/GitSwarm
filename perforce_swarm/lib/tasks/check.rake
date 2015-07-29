namespace :gitlab do
  desc 'GITSWARM | Check the configuration of GitSwarm and its environment'
  namespace :app do
    task check: ['perforce_swarm:check_override']
  end

  namespace :git_fusion do
    desc 'GITSWARM | Check the configutation of Git Fusion'
    task :check => :environment do
      puts "Checking the status of all configured Git Fusion instances... This might take a while.\n\n"
      results = PerforceSwarm::GitFusionConfig.check_configured_instances
      results.each do |result|
        exit(1) if result['outdated']
      end
    end
  end
end

namespace :perforce_swarm do
  task :check_override do
    define_method :omnibus_gitlab? do
      !(Dir.pwd =~ %r{/embedded/service/gitlab-rails}).nil?
    end
  end
end
