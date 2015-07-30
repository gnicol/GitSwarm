namespace :gitlab do
  desc 'GITSWARM | Check the configuration of GitSwarm and its environment'
  namespace :app do
    task check: ['perforce_swarm:check_override']
  end

  namespace :git_fusion do
    desc 'GITSWARM | Check the configutation of Git Fusion'
    task :check => :environment do
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
      exit(1) if outdated
    end

    def display_error(url, message)
      puts "\e[31mCould not connect to GitFusion instance at \e[37m#{url}\e[31m. Error: #{message}.\n" \
               "\tPlease update /etc/gitswarm/gitswarm.rb and re-run sudo gitswarm-ctl reconfigre.\e[0m\n\n"
    end

    def display_outdated_version_info(url, version)
      puts "\e[31mGit Fusion instance at \e[37m#{url}\e[31m is in an outdated version: \e[33m#{version}\e[31m."\
        " Min version required: \e[32m#{ENV['gf_min_version']}\e[0m\n\n"
    end

    def display_success_info(url, version)
      message = "\e[32mGit Fusion instance at \e[37m#{url}\e[32m is in version: \e[33m#{version}\e[0m\n\n"
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
