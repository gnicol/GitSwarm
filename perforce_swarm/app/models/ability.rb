require Rails.root.join('app', 'models', 'ability')

module PerforceSwarm
  module AbilitySelfExtension
    def allowed(user, subject)
      return not_auth_abilities(user, subject) if user.nil?
      return [] unless user.is_a?(User)
      return [] if user.blocked?
      return [] if subject.class.name == 'Project' && !user.authorized_projects.include?(subject)
      super
    end
  end
end

class Ability
  class << self
    prepend PerforceSwarm::AbilitySelfExtension
  end
end
