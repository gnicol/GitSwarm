namespace :gitlab do
  desc 'GITSWARM | Check the configuration of GitSwarm and its environment'
  namespace :app do
    task check: ['perforce_swarm:check_override']
  end

  namespace :git_fusion do
    desc 'GITSWARM | Check the configutation of Git Fusion'
    task check: :environment do
      puts "Checking the status of all configured Git Fusion instances...\n\n"
      min_version = ENV['gf_min_version'] || nil
      outdated = false
      PerforceSwarm::GitFusion.validate_entries(min_version) do |result|
        if !result[:valid] && result[:outdated]
          display_outdated_version_info(result[:config]['url'], result[:version])
          outdated = true
        elsif !result[:valid]
          display_error(result[:config]['url'], result[:error])
        else
          display_success_info(result[:config]['url'], result[:version])
        end
      end
      exit(66) if outdated
    end

    def display_error(url, message)
      puts "Could not connect to GitFusion instance at #{url.white}.".red + "Error: #{message}.\n".red +
       "\tPlease update /etc/gitswarm/gitswarm.rb and re-run sudo gitswarm-ctl reconfigre.\n\n".red
    end

    def display_outdated_version_info(url, version)
      puts "Git Fusion instance at #{url.white}".red + "is in an outdated version: #{version.yellow}".red +
        " Min version required: #{ENV['gf_min_version'].yellow}\n\n".red
    end

    def display_success_info(url, version)
      message = "Git Fusion instance at #{url.white}".green + " is in version: #{version.yellow}\n\n".green
      # output message if error, or output all if not quiet
      puts message unless ENV['gf_quiet']
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
