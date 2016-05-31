require Rails.root.join('app', 'services', 'merge_requests', 'post_merge_service')

module PerforceSwarm
  module PostMergeServiceExtension
    def execute(merge_request)
      # Remove source branch if merge request is flagged to do so
      if merge_request.should_remove_source_branch
        merge_request.should_remove_source_branch = false
        DeleteBranchService.new(merge_request.source_project, current_user)
                           .execute(merge_request.source_branch)
        merge_request.source_project.repository.expire_branch_names
      end

      super
    end
  end
end

class MergeRequests::PostMergeService
  prepend PerforceSwarm::PostMergeServiceExtension
end
