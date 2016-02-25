module PerforceSwarm
  module GitFusion
    module AutoCreateTemplates
      def path_template
        unless @config.auto_create['path_template']
          fail ConfigValidationError, 'Path template is not set in the auto create config.'
        end

        @config.auto_create['path_template']
      end

      # returns the depot path that Git Fusion should use to store a project's branches and files
      def depot_path
        @depot_path ||= render_template(path_template).chomp('/')
      end

      def repo_name
        @repo_name ||= render_template(repo_name_template)
      end

      def repo_name_template
        unless @config.auto_create['repo_name_template']
          fail ConfigValidationError, 'Repo name template is not set in the auto create config.'
        end

        @config.auto_create['repo_name_template']
      end

      def namespace(*args)
        if args.length > 0
          @namespace = args[0]
          return self
        end
        @namespace
      end

      def project_path(*args)
        if args.length > 0
          @project_path = args[0]
          return self
        end
        @project_path
      end

      # validates substitutions are valid and renders the given template
      def render_template(template)
        unless project_path && project_path.is_a?(String) && !project_path.empty?
          fail PerforceSwarm::GitFusion::RepoCreatorError, 'Project-path must be non-empty.'
        end

        unless namespace && namespace.is_a?(String) && !namespace.empty?
          fail PerforceSwarm::GitFusion::RepoCreatorError, 'Namespace must be non-empty.'
        end

        unless namespace =~ RepoCreator::VALID_NAME_REGEX
          fail PerforceSwarm::GitFusion::RepoCreatorError, "Namespace contains invalid characters: '#{namespace}'."
        end

        unless project_path =~ RepoCreator::VALID_NAME_REGEX
          fail PerforceSwarm::GitFusion::RepoCreatorError,
               "Project-path contains invalid characters: '#{project_path}'."
        end

        template.gsub('{project-path}', project_path).gsub('{namespace}', namespace)
      end
    end
  end
end
