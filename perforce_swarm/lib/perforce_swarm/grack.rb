module PerforceSwarm
  module GrackServerExtension
    def call(env)
      @env = env
      @req = Rack::Request.new(env)

      cmd, path, @reqfile, @rpc = match_routing
      @dir = get_git_dir(path)

      return super unless cmd == 'get_info_refs'

      # if we have a 'mirror' remote, pull from it before proceeding
      Dir.chdir(@dir) do
        if system('git config --get remote.mirror.url')
          unless system('git fetch mirror refs/*:refs/*')
            return [500, { 'Content-Type' => 'text/plain' }, ['Pull from mirror failed. You should fix that.']]
          end
        end
      end

      super
    end
  end
end

require 'grack'
class Grack::Server
  prepend PerforceSwarm::GrackServerExtension
end
