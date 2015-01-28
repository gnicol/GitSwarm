require File.expand_path('../../../spec/spec_helper', __FILE__)

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    js_errors: false,
    debug: true,
    timeout: 90,
    phantomjs_options: ['--proxy-type=socks5', '--proxy=0.0.0.0:0', '--debug=true']
  )
end
