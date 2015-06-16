module Gitlab
  module GitFusionImport
    class ProjectCreator
      attr_reader :repo, :namespace, :current_user

      def initialize(repo, namespace, current_user)
        @repo = repo
        @namespace = namespace
        @current_user = current_user
      end

      def execute
        ::Projects::CreateService.new(current_user,
                                      name: repo[:name],
                                      path: repo[:name],
                                      description: repo[:description],
                                      namespace_id: namespace.id,
                                      visibility_level: Gitlab::VisibilityLevel::PUBLIC,
                                      import_type: 'git_fusion',
                                      import_source: repo[:clone_url],
                                      import_url: repo[:clone_url]
        ).execute
      end
    end
  end
end
