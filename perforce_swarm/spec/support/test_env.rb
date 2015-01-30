require_relative '../../../spec/support/test_env'

module TestEnv
  def setup_gitlab_shell
    if ENV['GITLAB_SHELL_REPO']
      default_version = File.read(Rails.root.join('GITLAB_SHELL_VERSION')).strip
      ref  = ENV['GITLAB_SHELL_REF']  || "v#{default_version}"
      `rake 'gitlab:shell:install[#{ref},#{ENV['GITLAB_SHELL_REPO']}]'`
    else
      `rake gitlab:shell:install`
    end
  end
end
