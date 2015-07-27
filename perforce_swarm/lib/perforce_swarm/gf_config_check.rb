require '/opt/gitswarm/embedded/service/gitlab-shell/perforce_swarm/utils.rb'
require '/opt/gitswarm/embedded/service/gitlab-shell/perforce_swarm/git_fusion.rb'

module PerforceSwarm
  class GitFusionConfig
    def self.call_configured_instances
      # Get all keys from config, ignore enabled flag
      # probably smart to add a function to filter unnecessary data.
      # Call gf for each instance and save output
      @config = PerforceSwarm::GitlabConfig.new
      results = []
      @config.git_fusion_entries.each do |instance, _values|
        begin
          output = run(instance, 'info')
          version = output[/Git Fusion\/(\d{4}*)\.(\d{1,2}*)*/] || ''
        rescue RunError => ex
          results << display_error(@config.git_fusion[instance]['url'], ex.message)
        else
          results << display_info(@config.git_fusion[instance]['url'], version)
        end
      end
      results
    end

    def self.run(id, command, repo: nil, extra: nil)
      fail 'run requires a command' unless command
      config = PerforceSwarm::GitlabConfig.new.git_fusion_entry(id)
      url    = PerforceSwarm::GitFusion::URL.new(config['url']).command(command).repo(repo).extra(extra)
      Dir.mktmpdir do |temp|
        silenced = false
        output   = ''
        config_params = PerforceSwarm::GitFusion.git_config_params(config)
        Utils.popen(['git', *config_params, 'clone', '--', url.to_s], temp) do |line|
          # fatal: unable to access 'http://gitswarm@ul2.localhost/@info/': Couldn't resolve host 'ul2.localhost'
          fail RunAccessError, $LAST_MATCH_INFO['error'] if line =~ /^fatal: unable to access '[^']*': (?<error>.*)$/
          next if line =~ /^fatal: repository/ || silenced
          next if line =~ /^Cloning into/ || silenced
          output += line
        end
        return output.chomp
      end
    end

    def self.display_error(url, message)
      puts "\e[31mCould not connect to GitFusion instance at \e[37m#{url}\e[31m. Error: #{message}.\n" \
               "\tPlease update /etc/gitswarm/gitswarm.rb and re-run sudo gitswarm-ctl reconfigre.\e[0m\n\n"
      { 'url' => url, 'outdated' => false, 'connectible' => true }
    end

    def self.display_info(url, version)
      colour = "\e[32m"
      outdated = false
      additional_text = ''
      # if we have a min_version, add a check for that, and add information about it being/not being outdated
      if ENV['gf_min_version']
        min_version_year, min_version_number = ENV['gf_min_version'].split('.')
        version_year, version_number = version.split('/')[1].split('.')
        if version_year < min_version_year || (version_year <= min_version_year && version_number < min_version_number)
          colour = "\e[31m"
          outdated = true
          additional_text = '(outdated)'
        end
      end
      message = "#{colour}Git Fusion instance at \e[37m#{url}#{colour} is in version: \
        \e[33m#{version} #{additional_text}\e[0m\n\n"
      # output message if error, or output all if not quiet
      puts message if !ENV['gf_quiet'] || !additional_text.empty?
      { 'url' => url, 'outdated' => outdated, 'connectible'=> true }
    end
  end

  class RunError < RuntimeError
  end

  class RunAccessError < RunError
  end
end
