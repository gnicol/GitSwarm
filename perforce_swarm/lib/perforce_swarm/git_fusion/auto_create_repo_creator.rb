module PerforceSwarm
  module GitFusion
    class AutoCreateRepoCreator < RepoCreator
      attr_accessor :namespace, :project_path

      def self.validate_config(config)
        super(config)

        unless config.auto_create_configured?
          fail ConfigValidationError, 'Auto create is not configured properly.'
        end
      end

      def initialize(config_entry_id, namespace = nil, project_path = nil)
        super(config_entry_id)
        @namespace    = namespace
        @project_path = project_path
      end

      # returns the depot path that Git Fusion should use to store a project's branches and files
      def depot_path
        render_template(path_template).chomp('/')
      end

      def repo_name
        render_template(repo_name_template)
      end

      # returns the depot portion of the generated depot_path
      def project_depot
        PerforceSwarm::P4::Spec::Depot.id_from_path(path_template)
      end

      # generates the p4gf_config file that should be checked into Perforce under
      # //.git-fusion/repos/repo_name/p4gf_config
      def p4gf_config
        depot_branch_creation("#{depot_path}/{git_branch_name}")
        branch_mappings('master' => "#{depot_path}/master")
        super
      end

      def validate_depots(connection)
        depot_branch_creation("#{depot_path}/{git_branch_name}")
        super(connection)
      end

      # run pre-flight checks for:
      #  * project_depot pattern is valid
      #  * both //.git-fusion and the project depots exist
      #  * Git Fusion repo ID is not already in use (no p4gf_config for the specified repo ID)
      #  * Perforce has no content under the target project location
      # if any of the above conditions are not met, an exception is thrown
      def save_preflight(connection)
        if project_depot.include?('{namespace}') || project_depot.include?('{project-path}')
          fail 'Depot names cannot contain substitution variables ({namespace} or {project-path}).'
        end

        # ensure that the depots exist and there is not an existing p4gf_config file
        super(connection)

        if perforce_path_exists?(depot_path, connection)
          fail "It appears that there is already content in Helix at #{depot_path}."
        end
      end

      def path_template
        @config.auto_create['path_template']
      end

      def repo_name_template
        @config.auto_create['repo_name_template']
      end

      def namespace(*args)
        if args.length > 0
          self.namespace = args[0]
          return self
        end
        @namespace
      end

      def project_path(*args)
        if args.length > 0
          self.project_path = args[0]
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

        unless namespace =~ VALID_NAME_REGEX
          fail PerforceSwarm::GitFusion::RepoCreatorError, "Namespace contains invalid characters: '#{namespace}'."
        end

        unless project_path =~ VALID_NAME_REGEX
          fail PerforceSwarm::GitFusion::RepoCreatorError,
               "Project-path contains invalid characters: '#{project_path}'."
        end

        template.gsub('{project-path}', project_path).gsub('{namespace}', namespace)
      end
    end
  end
end
