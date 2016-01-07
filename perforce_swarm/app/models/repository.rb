require Rails.root.join('app', 'models', 'repository')

module PerforceSwarm
  module RepositoryExtension
    def commit_file(user, path, content, message, branch, update)
      PerforceSwarm::Mirror.fetch!(path_to_repo)
      super
    end

    def remove_file(user, path, message, branch)
      PerforceSwarm::Mirror.fetch!(path_to_repo)
      super
    end

    def commit_with_hooks(current_user, branch)
      begin
        socket_server = PerforceSwarm::MirrorLockSocketServer.new(path_to_repo)
        socket_server.start
        status = super
      ensure
        socket_server.stop if socket_server
      end
      status
    end
  end
end

class Repository
  prepend PerforceSwarm::RepositoryExtension
end
