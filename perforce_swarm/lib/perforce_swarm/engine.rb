module PerforceSwarm
  class Engine < ::Rails::Engine
    # Gitlab requires all their libs in an initializer, (config/initializers/2_app.rb)
    # So we will go ahead and do the same for ourselves
    initializer 'swarm_load_libs' do
      Dir["#{Rails.root}/perforce_swarm/lib/**/*.rb"].each { |file| require file }

      # Autoload classes from shell when needed
      shell_path = File.expand_path(Gitlab.config.gitlab_shell.path)
      PerforceSwarm.autoload :Mirror, File.join(shell_path, 'perforce_swarm', 'mirror')
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

    # Engine's public folder is searched first for assets
    initializer :static_assets do |app|
      app.middleware.insert_before(::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public")
    end
  end

  module ConfigurationExtension
    def initialize(*)
      super

      # Change the railties order so our engine comes first
      # This allows our routes and asset_paths to take precedence
      @railties_order = [PerforceSwarm::Engine, :main_app, :all]

      # Add our own lib directory as an rails autoload path. Gitlab adds theirs,
      # so doing ours first here allows our files to take precedence.
      paths.add 'perforce_swarm/lib', autoload: true
    end
  end
end

# Inject our custom config into the main rails application
class Rails::Application::Configuration
  prepend PerforceSwarm::ConfigurationExtension
end
