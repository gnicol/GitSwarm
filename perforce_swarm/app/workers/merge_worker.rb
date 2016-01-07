require Rails.root.join('app', 'workers', 'merge_worker')

module PerforceSwarm
  module MergeWorkerExtension
    def perform(merge_request_id, current_user_id, params)
      params        = params.with_indifferent_access
      current_user  = User.find(current_user_id)
      merge_request = ::MergeRequest.find(merge_request_id)

      # GitSwarm change, flag source for removal within the merge service,
      # instead of removing it here outside in the worker
      merge_request.should_remove_source_branch = true if params[:should_remove_source_branch].present?

      MergeRequests::MergeService.new(merge_request.target_project, current_user)
        .execute(merge_request)
    end
  end
end

class MergeWorker
  prepend PerforceSwarm::MergeWorkerExtension
end
