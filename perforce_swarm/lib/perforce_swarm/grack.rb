module PerforceSwarm
  module GrackServerExtension
    def call(env)
      @env = env
      @req = Rack::Request.new(env)

      cmd, path, @reqfile, @rpc = match_routing
      @dir = get_git_dir(path)

      return super unless cmd == 'get_info_refs'

      require File.join(Gitlab.config.gitlab_shell.path, 'perforce_swarm', 'mirror')
      begin
        PerforceSwarm::Mirror.fetch(@dir)
      rescue PerforceSwarm::Mirror::Exception => e
        return [500, { 'Content-Type' => 'text/plain' }, ["Pull from mirror failed.\n#{e.message}"]]
      end

      super
    end
  end
end

require 'grack'
class Grack::Server
  prepend PerforceSwarm::GrackServerExtension
end
