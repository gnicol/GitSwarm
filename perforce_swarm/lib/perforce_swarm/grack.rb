module PerforceSwarm
  module GrackServerExtension
    def call(env)
      @env = env
      @req = Rack::Request.new(env)

      cmd, path, @reqfile, @rpc = match_routing
      @git = get_git(path)

      return super unless PerforceSwarm::Repo.new(@git.repo).mirrored?

      # Fail if the service user hasn't been setup
      return [
        500,
        { 'Content-Type' => 'text/plain' },
        ['Mirror fetch failed because the gitswarm user doesn\'t exist in GitSwarm']
      ] unless User.find_by(username: 'gitswarm')

      return super unless cmd == 'get_info_refs'

      # push errors are fatal but pull errors are ignorable
      if @req['service'] == 'git-receive-pack'
        Mirror.fetch!(@git.repo)
      else
        Mirror.fetch(@git.repo)
      end

      super
    rescue Mirror::Exception => e
      return [500, { 'Content-Type' => 'text/plain' }, [e.message]]
    end
  end

  module GrackGitExtension
    def command(command)
      return super unless [*command].first == 'receive-pack'

      git_path            = @git_path || 'git'
      shell_path          = File.expand_path(Gitlab.config.gitlab_shell.path)
      swarm_receive_pack  = File.join(shell_path, 'perforce_swarm', 'bin', 'swarm-receive-pack')
      [swarm_receive_pack, "--git-path=#{git_path}"] + [*command][1..-1]
    end
  end
end

require 'grack'
class Grack::Server
  prepend PerforceSwarm::GrackServerExtension
end

class Grack::Git
  prepend PerforceSwarm::GrackGitExtension
end