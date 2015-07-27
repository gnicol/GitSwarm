namespace :gitlab do
  desc 'GITSWARM | Check the configuration of GitSwarm and its environment'
  namespace :app do
    task check: ['perforce_swarm:check_override']
  end

  namespace :git_fusion do
    desc 'GITSWARM | Check the configutation of GitFusion'
    task :check do |task, args|
      PerforceSwarm::GitFusionConfig.call_configured_instances
    end
  end

  def display_error(url)
    puts "\e[31mCould not connect to GitFusion instance at \e[37m#{url}\e[31m. Please check your configuration.\e[0m"
  end

  def display_info(url, version)
    colour = '\e[32m'
    additional = ''
    # if we have a min_version, add a check for that, and add information about it being/not being outdated
    if ENV['gf_min_version']
      min_version_year, min_version_number = ENV['gf_min_version'].split('.')
      version_year, version_number = version.split('/')[1].split('.')
      if version_year < min_version_year || (version_year <= min_version_year && version_number < min_version_number)
        colour = '\e[31m'
        additional = '(outdated)'
      end
    end
    message = "#{colour}Git Fusion instance at \e[37m#{url}#{colour} is in version: \e[33m#{version} #{additional}\e[0m"
    # output message if error, or output all if not quiet
    puts message if !ENV['gf_quiet'] || !additional.empty?
  end
end

namespace :perforce_swarm do
  task :check_override do
    define_method :omnibus_gitlab? do
      !(Dir.pwd =~ %r{/embedded/service/gitlab-rails}).nil?
    end
  end
end