module PerforceSwarm
  class Engine < ::Rails::Engine
    # Require our api changes before GitLab's in order to influence the api before it is mounted
    config.before_initialize do
      Dir["#{Rails.root}/perforce_swarm/lib/api/*.rb"].each { |file| require file }
    end

    # Gitlab requires all their libs in an initializer, (config/initializers/2_app.rb)
    # So we will go ahead and do the same for ourselves
    initializer 'swarm_load_libs' do
      Dir["#{Rails.root}/perforce_swarm/lib/**/*.rb"].each { |file| require file }

      # Autoload classes from shell when needed
      shell_path = File.expand_path(Gitlab.config.gitlab_shell.path)
      PerforceSwarm.autoload :Mirror, File.join(shell_path, 'perforce_swarm', 'mirror')
      PerforceSwarm.autoload :Repo, File.join(shell_path, 'perforce_swarm', 'repo')
      PerforceSwarm.autoload :GitlabConfig, File.join(shell_path, 'perforce_swarm', 'config')
      PerforceSwarm.autoload :GitFusion, File.join(shell_path, 'perforce_swarm', 'git_fusion')
    end

    # We want our engine's migrations to be run when the main app runs db:migrate
    # It seems as though stand-alone initializers run too late so the logic is here
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    initializer :engine_middleware do |app|
      # Engine's public folder is searched first for assets
      if app.config.serve_static_assets
        app.middleware.insert_before(Gitlab::Middleware::Static, ::ActionDispatch::Static, "#{root}/public")
      end

      # Override error pages (500) with our own versions
      app.middleware.insert_after(
        ::ActionDispatch::ShowExceptions,
        ::ActionDispatch::ShowExceptions,
        ::ActionDispatch::PublicExceptions.new("#{root}/public")
      )
    end
  end

  def self.edition
    unless defined? GITSWARM_EDITION
      const_set(:GITSWARM_EDITION, File.exist?(Rails.root.join('CHANGELOG-EE')) ? 'ee' : 'ce')
    end
    GITSWARM_EDITION
  end

  def self.ee?
    edition == 'ee'
  end
  def self.ce?
    edition == 'ce'
  end

  module ConfigurationExtension
    def initialize(*)
      super

      # Change the railties order so our engine comes first
      # This allows our routes and asset_paths to take precedence
      @railties_order = [PerforceSwarm::Engine, :main_app, :all]

      # Add our own directories as an rails autoload path. Gitlab adds theirs,
      # so doing ours first here allows our files to take precedence.
      # The GitLab paths that we are matching here can be found in their config/application.rb
      paths.add 'perforce_swarm/lib', autoload: true
      paths.add 'perforce_swarm/app/models/hooks', autoload: true
      paths.add 'perforce_swarm/app/models/concerns', autoload: true
      paths.add 'perforce_swarm/app/models/project_services', autoload: true
      paths.add 'perforce_swarm/app/models/members', autoload: true
    end
  end
end

# Inject our custom config into the main rails application
class Rails::Application::Configuration
  prepend PerforceSwarm::ConfigurationExtension
end
