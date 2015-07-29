module PerforceSwarm
  class GitFusionConfig
    def self.check_configured_instances
      # For every valid Git Fusion instance configuration
      # attempt connection and save appropriate result into an array for further processing
      min_version = ENV['gf_min_version'] || nil
      @entries = PerforceSwarm::GitFusion.validate_entries(min_version)
      @entries.each do |_instance, values|
        if !values[:valid]
          results << display_error(values[:config]['url'], values[:error])
        elsif values[:valid] && values[:outdated]
          results << display_outdated_version_info(values[:config]['url'], values[:version])
        else
          results << display_success_info(values[:config]['url'], values[:version])
        end
      end
      results
    end

    def self.display_error(url, message)
      puts "\e[31mCould not connect to GitFusion instance at \e[37m#{url}\e[31m. Error: #{message}.\n" \
               "\tPlease update /etc/gitswarm/gitswarm.rb and re-run sudo gitswarm-ctl reconfigre.\e[0m\n\n"
      { 'url' => url, 'outdated' => false, 'valid' => false }
    end

    def self.display_outdated_version_info(url, version)
      puts "\e[31mGit Fusion instance at \e[37m#{url}\e[31m is in version: \e[33m#{version}\e[0m\n\n"
      { 'url' => url, 'outdated' => true, 'valid' => true }
    end

    def self.display_success_info(url, version)
      puts "\e[32mGit Fusion instance at \e[37m#{url}\e[32m is in version: \e[33m#{version}\e[0m\n\n"
      # output message if error, or output all if not quiet
      puts message unless ENV['gf_quiet']
      { 'url' => url, 'outdated' => false, 'valid'=> true }
    end
  end
end
