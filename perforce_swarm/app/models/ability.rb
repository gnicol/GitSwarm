require Rails.root.join('app', 'models', 'ability')

module PerforceSwarm
  module AbilitySelfExtension
    def allowed(user, subject)
      return anonymous_abilities(user, subject) if user.nil?
      return [] unless user.is_a?(User)
      return [] if user.blocked?

      # Return no abilities if the subject is a mirrored project and the user doesn't have access to it
      return [] if subject.class.name == 'Project' &&
          subject.git_fusion_repo &&
          !GitFusion::RepoAccess.access?(user, subject)

      super
    end
  end
end

class Ability
  class << self
    prepend PerforceSwarm::AbilitySelfExtension
  end
end
