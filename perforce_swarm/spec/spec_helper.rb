require File.expand_path('../../../spec/spec_helper', __FILE__)

# Increase the timeout for the swarm specs, as they may start with JS enabled
# tests right from the start, and need to give rails some time to load
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 90)
end

RSpec.configure do
  # Fixes Rack::Timeout::RequestTimeoutError by
  # waiting longer than the default for our engine
  Slowpoke.timeout = 90
end
