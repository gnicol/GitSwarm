require Rails.root.join('app', 'models', 'merge_request')

module PerforceSwarm
  module MergeRequest
    def check_if_can_be_merged
      # If target and source projects don't match, we are on a fork and
      # we should try a mirror fetch on the source branch as well
      if source_project && source_project.id != target_project.id
        source_thread = Thread.new { Mirror.fetch(source_project.repository.path_to_repo) }
      end

      # Fetch from mirror
      target_success = Mirror.fetch(target_project.repository.path_to_repo)

      # If we stared a source thread, check it's value
      source_success = source_thread ? source_thread.value : true

      # If the fetch was successful, continue with GitLab's can merge check
      # Otherwise mark the merge as unmergable
      if target_success && source_success
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
