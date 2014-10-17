module PerforceSwarm
  class Engine < ::Rails::Engine
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
