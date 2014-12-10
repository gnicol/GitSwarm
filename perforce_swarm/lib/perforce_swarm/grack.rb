module PerforceSwarm
  module GrackServerExtension
    def call(env)
      @env = env
      @req = Rack::Request.new(env)

      cmd, path, @reqfile, @rpc = match_routing
      @dir = get_git_dir(path)

      system("echo EXTENZ! #{cmd} #{path} #{@dir} >> /tmp/itran")

      return super unless cmd == 'get_info_refs'

      Dir.chdir(@dir) do
        unless system('git fetch mirror refs/*:refs/*')
          return [500, { 'Content-Type' => 'text/plain' }, ['Update from mirror failed. You should fix that.']]
        end
      end

      super
    end
  end
end

require 'Grack'
class Grack::Server
  prepend PerforceSwarm::GrackServerExtension
end
