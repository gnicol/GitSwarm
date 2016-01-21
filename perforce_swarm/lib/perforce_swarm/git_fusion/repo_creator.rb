require 'fileutils'

module PerforceSwarm
  module GitFusion
    class RepoCreatorError < StandardError
    end

    class ConfigValidationError < RepoCreatorError
    end

    class FileAlreadyExists < RuntimeError
    end

    class RepoCreator
      VALID_NAME_REGEX = /\A([A-Za-z0-9_.-])+\z/

      attr_accessor :description, :namespace, :project_path
      attr_reader :config

      def self.validate_config(config)
        # we need at the very least have a config, an auto_create path_template and repo_name_template
        unless config.is_a?(PerforceSwarm::GitFusion::ConfigEntry)
          fail ConfigValidationError, '"config" must be a PerforceSwarm::GitFusion::ConfigEntry.'
        end

        unless config.auto_create_configured?
          fail ConfigValidationError, 'Auto create is not configured properly.'
        end
      end

      def initialize(config_entry_id, namespace = nil, project_path = nil)
        # config validation happens on assignment
        self.config   = PerforceSwarm::GitlabConfig.new.git_fusion.entry(config_entry_id)
        @namespace    = namespace
        @project_path = project_path
      end

      # returns the depot path that Git Fusion should use to store a project's branches and files
      def depot_path
        render_template(path_template).chomp('/')
      end

      # returns true if there are any files (even deleted) at the specified depot path, otherwise false
      def perforce_path_exists?(path, connection)
        # normalize path to not have a trailing slash or Perforce wildcard
        path.gsub!(%r{[/]+(\.\.\.)?$}, '')
        # check both the path as a file and path/... (as a directory)
        [path + '/...', path].each do |depot_path|
          begin
            connection.run('files', '-m1', depot_path)
            # if we found something, the path exists for our purposes
            return true
          rescue P4Exception => e
            # ignore messages due to non-existent files or depots
            raise e unless e.message.include?('- no such file') || e.message.include?('- must refer to client')
          end
        end
        false
      end

      def repo_name
        render_template(repo_name_template)
      end

      # returns the depot portion of the generated depot_path
      def project_depot
        PerforceSwarm::P4::Spec::Depot.id_from_path(path_template)
      end

      # returns the location of the p4gf_config file in Git Fusion's Perforce depot
      def perforce_p4gf_config_path
        "//.git-fusion/repos/#{repo_name}/p4gf_config"
      end

      # returns the path of the p4gf_config file to a given Perforce client root
      def local_p4gf_config_path(client_root)
        File.join(client_root, '.git-fusion', 'repos', repo_name, 'p4gf_config')
      end

      # generates the p4gf_config file that should be checked into Perforce under
      # //.git-fusion/repos/repo_name/p4gf_config
      def p4gf_config
        config_description  = 'Repo automatically created by GitSwarm.'
        config_description += @description ? ' ' + @description.tr("\n", ' ').strip : ''
        <<eof
[@repo]
description = #{config_description}
enable-git-submodules = yes
enable-git-merge-commits = yes
enable-git-branch-creation = yes
ignore-author-permissions = yes
depot-branch-creation-depot-path = #{depot_path}/{git_branch_name}
depot-branch-creation-enable = all

[master]
view = "#{depot_path}/master/..." ...
git-branch-name = master
eof
      end

      # ensure the depots exist - both the //.git-fusion one as well as the one the user wants to create their project
      def ensure_depots_exist(connection)
        depots  = [project_depot, '.git-fusion']
        missing = depots - PerforceSwarm::P4::Spec::Depot.exists?(connection, depots)
        if missing.length > 0
          fail 'The following depot(s) are required and were found to be missing: ' + missing.join(', ')
        end
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

        # ensure both //.git-fusion and project's target depots exist
        ensure_depots_exist(connection)

        # ensure there isn't already a Git Fusion repo with our ID or content under the target project location
        if perforce_path_exists?(perforce_p4gf_config_path, connection)
          fail "A Git Fusion repository already exists with the name (#{repo_name}). " \
               'You can import the existing Git Fusion repository into a new project.'
        end

        if perforce_path_exists?(depot_path, connection)
          fail "It appears that there is already content in Helix at #{depot_path}."
        end
      end

      # attempt to submit our p4gf_config file for Git Fusion - fails if a repo of the same name already exists
      def save
        p4 = PerforceSwarm::P4::Connection.new(@config)
        p4.login

        # run our pre-flight checks, which raises an exception if we shouldn't continue with the save
        save_preflight(p4)

        # generate our file and attempt to add it
        p4.with_temp_client do |tmpdir|
          file = local_p4gf_config_path(tmpdir)
          FileUtils.mkdir_p(File.dirname(file))
          File.write(file, p4gf_config)
          add_output = p4.run('add', file).shift
          if add_output.is_a?(String) && add_output.end_with?(" - can't add existing file")
            fail FileAlreadyExists, "Looks like #{repo_name} already exists."
          end

          begin
            p4.run('submit', '-d', 'GitSwarm adding a Git Fusion repo.', file)
          rescue P4Exception => e
            begin
              # revert the file we tried to commit
              p4.run('revert', file)

              # scrape the changelist and delete it
              change_id = e.message[/fix problems then use 'p4 submit -c (\d+)'\./, 1]
              p4.run('change', '-d', change_id) if change_id
            rescue StandardError => error
              # eat any exceptions thrown during cleanup - line needed for rubocop since it doesn't like empty rescues
              error.message
            end
            # re-raise the outer/original exception
            raise e
          end
        end
      ensure
        p4.disconnect if p4
      end

      def path_template
        @config.auto_create['path_template']
      end

      def repo_name_template
        @config.auto_create['repo_name_template']
      end

      def config=(config)
        PerforceSwarm::GitFusion::RepoCreator.validate_config(config)
        @config = config
      end

      def config(*args)
        if args.length > 0
          self.config = args[0]
          return self
        end
        @config
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

      def description(*args)
        if args.length > 0
          self.description = args[0]
          return self
        end
        @description
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
