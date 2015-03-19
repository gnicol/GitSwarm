module PerforceSwarm
  module GrackServerExtension
    def call(env)
      @env = env
      @req = Rack::Request.new(env)

      cmd, path, @reqfile, @rpc = match_routing
      @git = get_git(path)

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
end

require 'grack'
class Grack::Server
  prepend PerforceSwarm::GrackServerExtension
end
