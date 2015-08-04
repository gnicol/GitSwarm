require 'P4'
require 'request_store'

module PerforceSwarm
  # Lazy creates a P4 connection and hangs onto it for the life of a request.
  class P4
    def self.run(*args)
      connection.run(*args)
    end

    def self.connection
      return RequestStore.store[:p4] if RequestStore.store[:p4]

      config      = PerforceSwarm::Config.p4
      p4          = ::P4.new
      # hard-coded values not present in config by default
      p4.port     = config.port || 'ssl:1666'
      p4.user     = config.user || 'gitswarm'
      p4.password = config['password'] || ''
      p4.connect
      p4.run('trust -y')

      RequestStore.store[:p4] = p4
    end
  end
end
