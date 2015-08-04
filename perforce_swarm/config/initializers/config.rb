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

# gitswarm super user password for auto-provisioned p4d is in git-fusion's default configuration
PerforceSwarm::Config['git_fusion']['default'] ||= Settingslogic.new({})
