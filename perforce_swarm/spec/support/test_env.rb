require Rails.root.join('spec', 'support', 'test_env')

module TestEnv
  def setup_gitlab_shell
    ref  = ENV['GITLAB_SHELL_REF']  || nil
    repo = ENV['GITLAB_SHELL_REPO'] || nil

    if ref && repo
      `rake 'gitlab:shell:install[#{ref},#{repo}]'`
    else
      `rake gitlab:shell:install`
    end
  end
end
