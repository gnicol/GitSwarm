require Rails.root.join('lib', 'gitlab', 'satellite', 'satellite')

module PerforceSwarm
  module GitlabSatellite
    def update_from_source!
      # if we have a 'mirror' remote, pull from it before proceeding
      PerforceSwarm::Mirror.fetch(project.repository.path_to_repo)

      super
    rescue PerforceSwarm::Mirror::Exception => e
      raise Grit::Git::CommandFailed, e.message
    end
  end
end

class Gitlab::Satellite::Satellite
  prepend PerforceSwarm::GitlabSatellite
end
