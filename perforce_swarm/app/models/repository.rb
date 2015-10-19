require Rails.root.join('app', 'models', 'repository')

module PerforceSwarm
  module RepositoryExtension
    def commit_file(user, path, content, message, branch)
      PerforceSwarm::Mirror.fetch!(path_to_repo)
      super
    end

    def remove_file(user, path, message, branch)
      PerforceSwarm::Mirror.fetch!(path_to_repo)
      super
    end
  end
end

class Repository < ActiveRecord::Base
  prepend PerforceSwarm::RepositoryExtension
end
