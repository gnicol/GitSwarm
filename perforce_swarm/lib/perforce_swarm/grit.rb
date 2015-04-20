module PerforceSwarm
  module GritGitExtension
    def native(cmd, options = {}, *args, &block)
      # note command is likely a symbol; to_s call is therefore required
      if cmd.to_s == 'push'
        shell_path = File.expand_path(Gitlab.config.gitlab_shell.path)
        args.unshift('--receive-pack', File.join(shell_path, 'perforce_swarm', 'bin', 'swarm-receive-pack'))
      end

      super(cmd, options, *args, &block)
    end
  end
end

require 'grit'
class Grit::Git
  prepend PerforceSwarm::GritGitExtension
end
