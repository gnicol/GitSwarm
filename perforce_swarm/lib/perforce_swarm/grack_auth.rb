require Rails.root.join('lib', 'gitlab', 'backend', 'grack_auth')

module PerforceSwarm
  module GrackAuthExtension
    def render_grack_auth_ok
      # Fail if the service user hasn't been setup
      if PerforceSwarm::Repo.new(project.repository.path_to_repo).mirrored? && !User.find_by(username: 'gitswarm')
        return [
          500,
          { 'Content-Type' => 'text/plain' },
          ['Mirror fetch failed because the gitswarm user doesn\'t exist in GitSwarm']
        ]
      end
      super
    end
  end
end

class Grack::Auth
  prepend PerforceSwarm::GrackAuthExtension
end
