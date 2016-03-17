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
      quiet       = false
      outdated    = false

      # throw away the rake task name, and second one if its a -- to pass it to argparse
      ARGV.shift
      ARGV.shift if ARGV[0] == '--'
      op = OptionParser.new do |x|
        x.on('-q', '--quiet') { quiet = true }
        x.on('-vVERSION', '--min-version=VERSION', 'Minimal GF version') { |version| min_version = version }
      end
      op.parse!(ARGV)

      PerforceSwarm::GitlabConfig.new.git_fusion.validate_entries(min_version) do |result|
        if !result[:valid] && result[:outdated]
          display_outdated_version_info(result[:config]['url'], result[:version], min_version)
          outdated = true
        elsif !result[:valid]
          display_warning(result[:config]['url'], result[:error])
        else
          display_success_info(result[:config]['url'], result[:version]) unless quiet
        end
      end
      exit(66) if outdated
    end

    def display_warning(url, message)
      puts "Could not connect to GitFusion instance at #{url.to_s.white}.".yellow + " Message: #{message}.".yellow
      puts "\tPlease update /etc/gitswarm/gitswarm.rb and re-run 'sudo gitswarm-ctl reconfigure'.".yellow
      puts ''
    end

    def display_outdated_version_info(url, version, min_version)
      puts "Git Fusion instance at #{url.to_s.white}".red + " is in an outdated version: #{version.to_s.yellow}".red
      puts "\tMin version required: #{min_version.to_s.yellow}".red
      puts ''
    end

    def display_success_info(url, version)
      puts "Git Fusion instance at #{url.to_s.white}".green + " is in version: #{version.to_s.yellow}".green
      puts ''
    end
  end
end

namespace :perforce_swarm do
  task :check_override do
    define_method :omnibus_gitlab? do
      !(Dir.pwd =~ %r{/embedded/service/gitlab-rails}).nil?
    end

    define_method :start_checking do |component|
      component.gsub!(/GitLab/, 'GitSwarm')
      puts "Checking #{component.to_s.yellow} ..."
      puts ''
    end

    define_method :finished_checking do |component|
      component.gsub!(/GitLab/, 'GitSwarm')
      puts ''
      puts "Checking #{component.to_s.yellow} ... #{'Finished'.green}"
      puts ''
    end

    # Patch GitLab to require a git version >= 2.7.3
    # @TODO: Remove when codebase has moved onto GilLab >= 8.5.7 which already has this change
    define_method :check_git_version do
      required_version = Gitlab::VersionInfo.new(2, 7, 3)
      current_version = Gitlab::VersionInfo.parse(run(%W(#{Gitlab.config.git.bin_path} --version)))

      puts "Your git bin path is \"#{Gitlab.config.git.bin_path}\""
      print "Git version >= #{required_version} ? ... "

      if current_version.valid? && required_version <= current_version
        puts "yes (#{current_version})".green
      else
        puts 'no'.red
        try_fixing_it(
          "Update your git to a version >= #{required_version} from #{current_version}"
        )
        fix_and_rerun
      end
    end
  end
end
