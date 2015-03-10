require Rails.root.join('app', 'models', 'merge_request')

module PerforceSwarm
  module MergeRequest
    def check_if_can_be_merged
      # Fetch from mirror
      success = Mirror.fetch(target_project.repository.path_to_repo)
      # If target and souce projects don't match, we are on a fork and
      # we should try a mirror fetch on the source branch as well
      if success && source_project && source_project.id != target_project.id
        success = Mirror.fetch(source_project.repository.path_to_repo)
      end

      # If the fetch was successful, continue with GitLab's can merge check
      # Otherwise mark the merge as unmergable
      if success
        super
      else
        mark_as_unmergeable
      end
    end
  end
end

class MergeRequest < ActiveRecord::Base
  prepend PerforceSwarm::MergeRequest
end
