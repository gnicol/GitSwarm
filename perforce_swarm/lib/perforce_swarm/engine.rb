module PerforceSwarm
  class Engine < ::Rails::Engine
	
  # Change the railties order so our engine comes first
  # This allows our routes and asset_paths to take precedence
  module ConfigurationExtension
    def initialize(*)
      super
      @railties_order = [PerforceSwarm::Engine, :main_app, :all]
    end
  end
  
  initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end

# Inject our custom config into the main rails application
class Rails::Application::Configuration
  prepend PerforceSwarm::ConfigurationExtension
end
