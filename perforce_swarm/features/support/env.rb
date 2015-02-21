require 'simplecov' if ENV['SIMPLECOV']

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
Capybara.default_wait_time = 60
Capybara.ignore_hidden_elements = false

DatabaseCleaner.strategy = :truncation

Spinach.hooks.around_scenario do |_scenario_data, feature, &block|
  block.call

  # Cancel network requests by visiting the about:blank
  # page when using the poltergeist driver
  if ::Capybara.current_driver == :poltergeist
    # Clear local storage after each scenario
    # We should be able to drop this when the 1.6 release of poltergiest comes out
    # where they will do it for us after each test
    feature.page.execute_script('window.localStorage.clear()')
    feature.visit 'about:blank'
    feature.find(:css, 'body').text.should feature.eq('')
    wait_for_requests
  end
end

Spinach.hooks.before_scenario do
  DatabaseCleaner.start
end

Spinach.hooks.after_scenario do
  DatabaseCleaner.clean
end

Spinach.hooks.before_run do
  include RSpec::Mocks::ExampleMethods
  TestEnv.init(mailer: false)

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

def wait_for_requests
  RackRequestBlocker.block_requests!
  Timeout.timeout(Capybara.default_wait_time) do
    loop { break if RackRequestBlocker.num_active_requests == 0 }
  end
ensure
  RackRequestBlocker.allow_requests!
end
