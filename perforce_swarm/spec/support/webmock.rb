require_relative '../../../spec/support/webmock'

# stub requests to updates.perforce.com for check for updates
WebMock.stub_request(:get, %r{https://updates\.perforce\.com/static/GitSwarm/GitSwarm(\-ee)?\.json})
  .to_return(status: 200, body: '{"versions":[]}', headers: {})
