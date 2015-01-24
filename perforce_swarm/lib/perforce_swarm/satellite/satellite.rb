require Rails.root.join('lib', 'gitlab', 'satellite', 'satellite')
require File.join(Gitlab.config.gitlab_shell.path, 'perforce_swarm', 'mirror')

module PerforceSwarm
  module GitlabSatelliteExtension
    def update_from_source!
      # if we have a 'mirror' remote, pull from it before proceeding
      PerforceSwarm::Mirror.fetch(project.repository.path_to_repo)

      super
    end
  end
end

class Gitlab::Satellite::Satellite
  prepend PerforceSwarm::GitlabSatelliteExtension
end
