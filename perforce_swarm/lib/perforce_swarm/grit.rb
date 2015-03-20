module PerforceSwarm
  module GritGitExtension
    def native(cmd, options = {}, *args, &block)
      if cmd.to_s == 'push'
        shell_path = File.expand_path(Gitlab.config.gitlab_shell.path)
        args = ['--receive-pack', File.join(shell_path, 'perforce_swarm', 'bin', 'swarm-receive-pack').to_s] + args
      end

      super(cmd, options, *args, &block)
    end
  end
end

require 'grit'
class Grit::Git
  prepend PerforceSwarm::GritGitExtension
end
