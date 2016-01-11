require_relative '../../../spec/support/webmock'

RSpec.configure do |config|
  # in webmock/rspec, stubs are reset after each run. Set a gloabl stub here for our version updates
  config.before :each do
    # stub requests to updates.perforce.com for check for updates
    WebMock.stub_request(:get, %r{https://updates\.perforce\.com/static/GitSwarm/GitSwarm(\-ee)?\.json})
      .to_return(status: 200, body: '{"versions":[]}', headers: {})
  end
end
