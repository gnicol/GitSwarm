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

      # returns true/false whether there is already content in the depot path where we are expecting to store a project
      def depot_path_content?
        path = depot_path + '/...'

        # run an fstat on the depot path to ensure there are no files present
        p4 = PerforceSwarm::P4::Connection.new(@config)
        p4.with_temp_client do |_tmpdir|
          files = p4.run('fstat', '-m1', path.gsub(%r{//}, '//' + p4.client + '/'))
          return !files.empty?
        end
      rescue P4Exception => e
        return false if e.message.include?('- no such file')
        # unexpected error, so re-raise
        raise e
      ensure
        p4.disconnect if p4
      end

      def repo_name
        render_template(repo_name_template)
      end

      # returns the depot portion of the generated depot_path
      def project_depot
        path_template[%r{\A//([^/]+)/}, 1]
      end

      # generates the p4gf_config file that should be checked into Perforce under
      # //.git-fusion/repos/repo_name/p4gf_config
      def p4gf_config
        config_description  = 'Repo automatically created by GitSwarm.'
        config_description += @description ? ' ' + @description.gsub("\n", ' ').strip : ''
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

      # attempt to submit our p4gf_config file for Git Fusion - fails if a repo of the same name already exists
      def save
        p4 = PerforceSwarm::P4::Connection.new(@config)
        p4.login

        # ensure the depots exist - both the //.git-fusion one as well as the one the user wants to create their project
        if project_depot.include?('{namespace}') || project_depot.include?('{project-path}')
          fail 'Depot names cannot contain substitution variables ({namespace} or {project-path}).'
        end

        depots   = [project_depot, '.git-fusion']
        missing  = depots - PerforceSwarm::P4::Spec::Depot.exists?(p4, depots)
        if missing.length > 0
          fail 'The following depot(s) are required and were found to be missing: ' + missing.join(', ')
        end

        # generate our file and attempt to add it
        p4.with_temp_client do |tmpdir|
          file = File.join(tmpdir, '.git-fusion', 'repos', repo_name, 'p4gf_config')
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
