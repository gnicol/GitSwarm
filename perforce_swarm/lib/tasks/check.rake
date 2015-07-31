require 'optparse'

namespace :gitlab do
  desc 'GITSWARM | Check the configuration of GitSwarm and its environment'
  namespace :app do
    task check: ['perforce_swarm:check_override']
  end

  namespace :git_fusion do
    desc 'GITSWARM | Check the configuration of Git Fusion'
    task check: :environment do
      puts 'Checking the status of all configured Git Fusion instances...'
      puts ''
      min_version = nil
      quiet = false
      outdated = false

      # throw away the rake task name, and second one if its a -- to pass it to argparse
      ARGV.shift
      ARGV.shift if ARGV[0] == '--'
      op = OptionParser.new do |x|
        x.on('-q', '--quiet') { quiet = true }
        x.on('-vVERSION', '--min_version=VERSION', 'Minimal GF version') { |version| min_version = version }
      end
      op.parse!(ARGV)

      PerforceSwarm::GitFusion.validate_entries(min_version) do |result|
        if !result[:valid] && result[:outdated]
          display_outdated_version_info(result[:config]['url'], result[:version], min_version)
          outdated = true
        elsif !result[:valid]
          display_error(result[:config]['url'], result[:error])
        else
          display_success_info(result[:config]['url'], result[:version]) unless quiet
        end
      end
      exit(66) if outdated
    end

    def display_error(url, message)
      puts "Could not connect to GitFusion instance at #{url.white}.".red + "Error: #{message}.".red
      puts '\tPlease update /etc/gitswarm/gitswarm.rb and re-run "sudo gitswarm-ctl reconfigre".'.red
      puts ''
    end

    def display_outdated_version_info(url, version, min_version)
      puts "Git Fusion instance at #{url.white}".red + " is in an outdated version: #{version.yellow}".red
      puts "\tMin version required: #{min_version.yellow}".red
      puts ''
    end

    def display_success_info(url, version)
      puts "Git Fusion instance at #{url.white}".green + " is in version: #{version.yellow}\n\n".green
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
