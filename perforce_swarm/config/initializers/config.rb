module PerforceSwarm
  class Config < Settingslogic
    if File.exists? "#{__dir__}/../config.yml"
      source("#{__dir__}/../config.yml")
    else
      source({})
    end
    namespace Rails.env
  end
end

# Perforce Config
PerforceSwarm::Config['p4'] ||= Settingslogic.new({})
