if ENV['RAILS_ENV'] == 'test'
  require 'spinach'
  require_relative '../../spec/support/test_env'
  require_relative '../../features/support/rack_request_blocker'

  PerforceSwarm::Engine.initializer 'request_blocker' do |app|
    # Make sure the middleware is inserted first in middleware chain
    app.middleware.insert_before('Gitlab::Middleware::Static', 'RackRequestBlocker')
  end

  Spinach.hooks.before_run do
    # Creating a hash of all feature names (keys) and corresponding list of scenarios (values) that need to be SKIPPED
    # All scenarios in parent application that need to be skipped should be marked with a '@skip-parent' tag
    # in the rails engine, for a dummy scenario with the same name & feature location as the parent
    skipped_scenarios = Hash.new
    Dir["#{Rails.root}/perforce_swarm/features/**/*.feature"].each do |engine_file|
      app_file = engine_file.gsub(/\/perforce_swarm/, '')
      next unless File.exist?(app_file)

      feature_name = `grep 'Feature:' #{engine_file} |sed 's/Feature: *//g'`.strip
      local_skipped_scenarios = `grep -C 1 '@skip-parent' #{engine_file} |grep 'Scenario:'|sed 's/Scenario: *//g'`
                                .split("\n")
                                .each { |a| a.strip! if a.respond_to? :strip! }
      if local_skipped_scenarios.any?
        skipped_scenarios[feature_name] = local_skipped_scenarios
      end
    end

    # Modifying the Spinach 'Features' object so that it skips the list of scenarios specified by 'skipped_scenarios'
    Spinach.hooks.before_feature do |feature|
      if skipped_scenarios.key?(feature.name)
        feature.scenarios.select! do |scenario|
          !skipped_scenarios[feature.name].include?(scenario.name)
        end
      end
    end

    # Add overridden steps from the engine to the parent application's path
    Dir.glob(
        File.expand_path File.join(Rails.root, 'perforce_swarm', 'features', 'steps', '**', '*.rb')
    ).sort { |a, b| [b.count(File::SEPARATOR), a] <=> [a.count(File::SEPARATOR), b] }.each do |file|
      require file
    end
  end
end
