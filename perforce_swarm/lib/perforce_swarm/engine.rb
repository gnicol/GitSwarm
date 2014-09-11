module PerforceSwarm
  class Engine < ::Rails::Engine
    isolate_namespace PerforceSwarm
    
    config.after_initialize do |app|
      app.routes.prepend do
        mount PerforceSwarm::Engine, at: "/"
      end
    end
  end
end
