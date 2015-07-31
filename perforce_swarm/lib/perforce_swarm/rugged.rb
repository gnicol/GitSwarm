require 'rugged'

module PerforceSwarm
  module RuggedBranchCollection
    # Filter remote branches out of the branch listing by default
    def each(filter = :local)
      super
    end
  end

  module RuggedCommit
    # Push to mirror before updating commit references
    def create(repo, data)
      # Don't bother pushing to mirror if they weren't going to update
      # references, or if the passed repo isn't a mirrored repo
      unless data[:update_ref] &&
             repo.path.start_with?(Gitlab.config.gitlab_shell.repos_path.to_s) &&
             PerforceSwarm::Repo.new(repo.path).mirrored?
        return super
      end

      # Grab the latest from the mirror, so if this change ends up being
      # non-fast-forward and fails, you get the latest code when you refresh
      Mirror.fetch!(repo.path)

      # Hang onto the update_ref, we will need to manually update the refs in case of mirroring
      update_ref = data[:update_ref]

      # Detect if the fetch already moved our branch forward, in which case we can
      # throw the same error commit would have if it was being passed update_ref
      if data[:parents] && data[:parents].size > 0 &&
         repo.references.exist?(update_ref) && data[:parents][0] != repo.references[update_ref].target
        fail Rugged::ObjectError, 'failed to create commit: current tip is not the first parent'
      end

      commit_id = nil
      resolver  = proc do |_mirror_repo, mirror_refs|
        # If mirror_refs is empty, it means no mirror push is going to happen.
        # If no mirror push is going to happen, we just let super update the ref.
        data[:update_ref] = nil unless mirror_refs.to_a.empty?

        commit_id = super(repo, data)
        ["#{commit_id}:#{update_ref}"]
      end

      # Pass invalid ref sha, we will update it with the valid commit id
      # in the resolver before the push actually happens
      Mirror.push(["0123456789abcdef:#{update_ref}"], repo.path, refs_resolver: resolver) do
        # We only need to update the ref if super hasn't already done so
        # We force: true to match commit:create's behaviour of creating new branches
        repo.references.create(update_ref, commit_id, force: true) unless data[:update_ref]
      end
      commit_id
    end
  end
end

class Rugged::BranchCollection
  prepend PerforceSwarm::RuggedBranchCollection
end

class Rugged::Commit
  class << self
    prepend PerforceSwarm::RuggedCommit
  end
end
