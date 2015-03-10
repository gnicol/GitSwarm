require Rails.root.join('lib', 'gitlab', 'satellite', 'merge_action')

module PerforceSwarm
  module GitlabSatelliteMergeAction
    def merge!(merge_commit_message = nil)
      # Fetch from mirror before merge
      Mirror.fetch!(merge_request.target_project.repository.path_to_repo)
      # If target and souce projects don't match, we are on a fork and
      # we should try a mirror fetch on the source branch as well
      if merge_request.source_project && merge_request.source_project.id != merge_request.target_project.id
        Mirror.fetch!(merge_request.source_project.repository.path_to_repo)
      end
      super
    rescue Errno::ENOMEM => e
      handle_exception(e)
    rescue Mirror::Exception => e
      # Mark the request as unmergable if fetch failed
      merge_request.mark_as_unmergeable
      handle_exception(e)
    end
  end
end

class Gitlab::Satellite::MergeAction < Gitlab::Satellite::Action
  prepend PerforceSwarm::GitlabSatelliteMergeAction
end
