require Rails.root.join('lib', 'gitlab', 'satellite', 'merge_action')

module PerforceSwarm
  module GitlabSatelliteMergeAction
    def merge!(merge_commit_message = nil)
      # If target and source projects don't match, we are on a fork and
      # we should try a mirror fetch on the source branch as well
      if merge_request.source_project && merge_request.source_project.id != merge_request.target_project.id
        source_thread = Thread.new { Mirror.fetch!(merge_request.source_project.repository.path_to_repo) }
      end

      # Fetch from mirror before merge
      Mirror.fetch!(merge_request.target_project.repository.path_to_repo)

      # If we started a source_thread, wait for it to complete
      source_thread.join if source_thread

      super
    rescue Mirror::Exception => e
      # Log the exception
      handle_exception(e)

      # Re-raise the exception in order to mark the request as unmergable
      raise e
    end
  end
end

class Gitlab::Satellite::MergeAction < Gitlab::Satellite::Action
  prepend PerforceSwarm::GitlabSatelliteMergeAction
end
