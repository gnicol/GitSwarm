module PerforceSwarm
  class Engine < ::Rails::Engine
  end

  # Change the railties order so our engine comes first
  # This allows our routes and asset_paths to take precedence
  module ConfigurationExtension
    def initialize(*)
      super
      @railties_order = [PerforceSwarm::Engine, :main_app, :all]
    end
  end
end

# Inject our custom config into the main rails application
class Rails::Application::Configuration
  prepend PerforceSwarm::ConfigurationExtension
end
