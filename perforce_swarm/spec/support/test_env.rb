require_relative '../../../spec/support/test_env'

module PerforceSwarm
  module TestEnvSelf
    def setup_gitlab_shell
      repo = ENV['GITLAB_SHELL_REPO'] || 'http://gitlab.perforce.com/p4gitlab/gitlab-shell.git'
      ref  = ENV['GITLAB_SHELL_REF']  || File.read(Rails.root.join('perforce_swarm', '.codeline'))
      `rake gitlab:shell:install['#{ref.strip}','#{repo.strip}']`
    end
  end
end

module TestEnv
  class << self
    prepend PerforceSwarm::TestEnvSelf
  end
end
