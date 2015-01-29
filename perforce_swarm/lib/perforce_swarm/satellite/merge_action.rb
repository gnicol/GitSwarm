require Rails.root.join('lib', 'gitlab', 'satellite', 'merge_action')

module PerforceSwarm
  module GitlabSatelliteMergeAction
    def update_satellite_source_and_target!(repo)
      # @todo: if the source and origin remote is the same, we can skip this second fetch
      # if we have a 'mirror' remote, pull from it before proceeding
      PerforceSwarm::Mirror.fetch(merge_request.source_project.repository.path_to_repo)

      super
    rescue PerforceSwarm::Mirror::Exception => e
      handle_exception(e)
    end
  end
end

class Gitlab::Satellite::MergeAction < Gitlab::Satellite::Action
  prepend PerforceSwarm::GitlabSatelliteMergeAction
end
