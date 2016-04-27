require Rails.root.join('app', 'models', 'repository')

module PerforceSwarm
  module RepositoryExtension
    def commit_file(user, path, content, message, branch, update)
      PerforceSwarm::Mirror.fetch!(path_to_repo)
      super
    rescue Mirror::Exception => e
      raise Repository::CommitError, "Helix Mirroring Error: #{e.message}"
    end

    def remove_file(user, path, message, branch)
      PerforceSwarm::Mirror.fetch!(path_to_repo)
      super
    rescue Mirror::Exception => e
      raise Repository::CommitError, "Helix Mirroring Error: #{e.message}"
    end

    def add_branch(user, branch_name, target)
      begin
        socket_server = PerforceSwarm::MirrorLockSocketServer.new(path_to_repo)
        socket_server.start
        status = super
      ensure
        socket_server.stop if socket_server
      end
      status
    end

    def rm_branch(user, branch_name)
      begin
        socket_server = PerforceSwarm::MirrorLockSocketServer.new(path_to_repo)
        socket_server.start
        status = super
      ensure
        socket_server.stop if socket_server
      end
      status
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

    def reload_raw_repository
      @raw_repository = nil
      raw_repository
    end
  end
end

class Repository
  prepend PerforceSwarm::RepositoryExtension

  # define directly so we can stub it out in the spec tests (RSpec does not
  # support stubbing of prepended class methods)
  def skip_ci?
    File.exist?(File.join(path_to_repo, '.skip-ci'))
  end
end
