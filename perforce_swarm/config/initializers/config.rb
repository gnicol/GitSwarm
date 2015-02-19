module PerforceSwarm
  class Config < Settingslogic
    if File.exist? "#{__dir__}/../config.yml"
      source("#{__dir__}/../config.yml")
    else
      source({})
    end
    namespace Rails.env
  end
end

PerforceSwarm::Config['p4'] ||= Settingslogic.new({})
