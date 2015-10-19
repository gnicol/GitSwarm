require Rails.root.join('app', 'models', 'repository')

module PerforceSwarm
  module RepositoryExtension
    def commit_file(user, path, content, message, branch)
      PerforceSwarm::Mirror.fetch!(path_to_repo)
      super
    end

    def remove_file(user, path, message, branch)
      PerforceSwarm::Mirror.fetch!(path_to_repo)
      super
    end

    def commit_with_hooks(current_user, branch)
      oldrev = Gitlab::Git::BLANK_SHA
      ref = Gitlab::Git::BRANCH_REF_PREFIX + branch
      gl_id = Gitlab::ShellEnv.gl_id(current_user)
      was_empty = empty?

      # Create temporary ref
      random_string = SecureRandom.hex
      tmp_ref = "refs/tmp/#{random_string}/head"

      unless was_empty
        oldrev = find_branch(branch).target
        rugged.references.create(tmp_ref, oldrev)
      end

      # Make commit in tmp ref
      newrev = yield(tmp_ref)

      fail CommitError, 'Failed to create commit' unless newrev

      begin
        socket_server = PerforceSwarm::MirrorLockSocketServer.new(path_to_repo)
        socket_server.start
        # Run GitLab pre-receive hook
        pre_receive_hook = Gitlab::Git::Hook.new('pre-receive', path_to_repo)
        status = pre_receive_hook.trigger(gl_id, oldrev, newrev, ref)

        if status
          if was_empty
            # Create branch
            rugged.references.create(ref, newrev)
          else
            # Update head
            current_head = find_branch(branch).target

            # Make sure target branch was not changed during pre-receive hook
            if current_head == oldrev
              rugged.references.update(ref, newrev)
            else
              fail CommitError, 'Commit was rejected because branch received new push'
            end
          end

          # Run GitLab post receive hook
          post_receive_hook = Gitlab::Git::Hook.new('post-receive', path_to_repo)
          status = post_receive_hook.trigger(gl_id, oldrev, newrev, ref)
        else
          # Remove tmp ref and return error to user
          rugged.references.delete(tmp_ref)

          fail PreReceiveError, 'Commit was rejected by pre-receive hook'
        end
      ensure
        socket_server.stop
      end
      status
    end
  end
end

class Repository
  prepend PerforceSwarm::RepositoryExtension
end
