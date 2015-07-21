require 'simplecov' if ENV['SIMPLECOV']

if ENV['COVERALLS']
  require 'coveralls'
  Coveralls.wear_merged!
end

ENV['RAILS_ENV'] = 'test'
require './config/environment'
require 'rspec/expectations'
require 'database_cleaner'
require 'spinach/capybara'
require 'sidekiq/testing/inline'

%w(select2_helper test_env repo_helpers).each do |f|
  require Rails.root.join('spec', 'support', f)
end

Dir["#{Rails.root}/features/steps/shared/*.rb"].each { |file| require file }
Dir["#{Rails.root}/perforce_swarm/features/steps/shared/*.rb"].each { |file| require file }

WebMock.allow_net_connect!
#
# JS driver
#
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 90)
end
Spinach.hooks.on_tag('javascript') do
  ::Capybara.current_driver = ::Capybara.javascript_driver
end
Capybara.default_wait_time = 90
Capybara.ignore_hidden_elements = false

DatabaseCleaner.strategy = :truncation

Spinach.hooks.before_scenario do
  DatabaseCleaner.start
end

Spinach.hooks.after_scenario do
  DatabaseCleaner.clean
end

Spinach.hooks.before_run do
  include RSpec::Mocks::ExampleMethods
  TestEnv.init(mailer: false)

  # Include the test license helper if EE edition
  if PerforceSwarm.ee?
    require Rails.root.join('spec', 'support', 'license')
    TestLicense.init
  end

  include FactoryGirl::Syntax::Methods
end

def wait_for_ajax
  Timeout.timeout(Capybara.default_wait_time) do
    loop do
      active = page.evaluate_script('jQuery.active').to_i
      break if active == 0
    end
  end
rescue
  raise "AJAX request took longer than #{Capybara.default_wait_time} seconds."
end