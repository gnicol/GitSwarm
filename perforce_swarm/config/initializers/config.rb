module PerforceSwarm
  class Config < Settingslogic
    source "#{__dir__}/../config.yml"
    namespace Rails.env
  end
end

# Perforce Config
PerforceSwarm::Config['perforce'] ||= Settingslogic.new({})
