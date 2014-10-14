if ENV['SIMPLECOV']
  require 'simplecov'
end

if ENV['COVERALLS']
  require 'coveralls'
  Coveralls.wear_merged!
end

ENV['RAILS_ENV'] = 'test'
require './config/environment'
require 'rspec'
require 'rspec/expectations'
require 'database_cleaner'
require 'spinach/capybara'
require 'sidekiq/testing/inline'

%w(select2_helper test_env repo_helpers).each do |f|
  require Rails.root.join('spec', 'support', f)
end

Dir["#{Rails.root}/features/steps/shared/*.rb"].each {|file| require file}

WebMock.allow_net_connect!
#
# JS driver
#
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 90)
end
Spinach.hooks.on_tag("javascript") do
  ::Capybara.current_driver = ::Capybara.javascript_driver
end
Capybara.default_wait_time = 60
Capybara.ignore_hidden_elements = false

DatabaseCleaner.strategy = :truncation

Spinach.hooks.before_scenario do
  DatabaseCleaner.start
end

Spinach.hooks.after_scenario do
  DatabaseCleaner.clean
end

Spinach.hooks.before_run do
  TestEnv.init(mailer: false)
  RSpec::Mocks::setup self

  include FactoryGirl::Syntax::Methods
end

# Creating a hash of all feature names (keys) and corresponding list of scenarios (values) that need to be SKIPPED
# All scenarios in parent application that need to be skipped should be marked with a '@skip-parent' tag
# in the rails engine, for a dummy scenario with the same name & feature location as the parent
skipped_scenarios = Hash.new
Dir["#{Rails.root}/perforce_swarm/features/**/*.feature"].each {|engine_file|
  app_file = engine_file.gsub(/\/perforce_swarm/, '')
  if File.exist?(app_file)
    feature_name =  %x(grep 'Feature:' #{engine_file} |sed 's/Feature: *//g').strip
    local_skipped_scenarios = %x(grep -C 1 '@skip-parent' #{engine_file} |grep 'Scenario:'|sed 's/Scenario: *//g').
        split("\n").
        each {|a| a.strip! if a.respond_to? :strip! }
    if local_skipped_scenarios.any?
      skipped_scenarios[feature_name] = local_skipped_scenarios
    end
  end
}

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
    File.expand_path File.join(Rails.root, "perforce_swarm", "features", "steps", '**', '*.rb')
).sort{|a,b| [b.count(File::SEPARATOR), a] <=> [a.count(File::SEPARATOR), b]}.each do |file|
  require file
end
