require Rails.root.join('lib', 'gitlab', 'identifier')

module PerforceSwarm
  module Identifier
    # @todo: group commits in order by author, and credit author for push if they are a GitLab user
    def identify(identifier, project, newrev)
      # Check if a system user was provided, and use it if it exists
      if identifier == Mirror::SYSTEM_USER
        user = User.find_by(username: 'gitswarm')
        return user if user

        # If the service user doesn't exist, pretend that nil
        # user was passed and fallback to default behaviour
        identifier = nil
      end
      super(identifier, project, newrev)
    end
  end
end

module Gitlab::Identifier
  prepend PerforceSwarm::Identifier
end
