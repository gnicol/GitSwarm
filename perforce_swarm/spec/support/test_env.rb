require_relative '../../../spec/support/test_env'

module PerforceSwarm
  module TestEnv
    def setup_gitlab_shell
      return super unless ENV['GITLAB_SHELL_REPO']

      default_version = File.read(Rails.root.join('GITLAB_SHELL_VERSION')).strip
      ref  = ENV['GITLAB_SHELL_REF']  || "v#{default_version}"
      `rake 'gitlab:shell:install[#{ref},#{ENV['GITLAB_SHELL_REPO']}]'`
    end
  end
end

module TestEnv
  prepend PerforceSwarm::TestEnv
end
