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
      VALID_NAME_REGEX ||= /\A([A-Za-z0-9_.-])+\z/

      attr_accessor :description, :branch_mappings, :depot_branch_creation
      attr_reader :config

      def self.validate_config(config)
        # we need at the very least have a config, an auto_create path_template and repo_name_template
        unless config.is_a?(PerforceSwarm::GitFusion::ConfigEntry)
          fail ConfigValidationError, '"config" must be a PerforceSwarm::GitFusion::ConfigEntry.'
        end
      end

      def self.validate_depot_path(path)
        fail 'Empty depot path specified.' unless path && !path.empty?
        unless path.start_with?('//') && PerforceSwarm::P4::Spec::Depot.id_from_path(path)
          fail "Specified path '#{path}' does not appear to be a valid depot path."
        end
      end

      def self.validate_branch_mappings(branch_mappings)
        if !branch_mappings || !branch_mappings.is_a?(Hash)
          fail P4GFConfigError, 'No branch mappings specified.'
        end

        # check all the branch mappings
        branch_mappings.each do |name, path|
          fail "Invalid name '#{name}' specified in branch mapping." unless VALID_NAME_REGEX.match(name)
          validate_depot_path(path)
        end
      end

      def initialize(config_entry_id, repo_name = nil, branch_mappings = nil, depot_branch_creation = false)
        # config validation happens on assignment
        self.config            = PerforceSwarm::GitlabConfig.new.git_fusion.entry(config_entry_id)
        @repo_name             = repo_name
        @branch_mappings       = branch_mappings
        @depot_branch_creation = depot_branch_creation
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

        config = ['[@repo]']
        config << "description = #{config_description}"
        config << 'enable-git-submodules = yes'
        config << 'enable-git-merge-commits = yes'
        config << 'enable-git-branch-creation = yes'
        config << 'ignore-author-permissions = yes'

        if depot_branch_creation
          config << "depot-branch-creation-depot-path = #{depot_branch_creation}"
          config << 'depot-branch-creation-enable = all'
        end

        config << ''
        branch_mappings.each do |name, path|
          path.gsub!(%r{\/+(\.\.\.)?$}, '')
          config << "[#{name}]"
          config << "view = \"#{path}/...\" ..."
          config << "git-branch-name = #{name}"
        end
        config << ''

        config.join("\n")
      end

      # ensure the depots exist - both //.git-fusion as well as any depot paths referenced in
      # depot branch creation or in the given branch mappings
      def ensure_depots_exist(connection)
        depots = ['.git-fusion']
        depots << PerforceSwarm::P4::Spec::Depot.id_from_path(depot_branch_creation) if depot_branch_creation
        if branch_mappings
          branch_mappings.each do |_name, depot_path|
            depots << PerforceSwarm::P4::Spec::Depot.id_from_path(depot_path)
          end
        end
        depots.uniq!

        missing = depots - PerforceSwarm::P4::Spec::Depot.exists?(connection, depots)
        if missing.length > 0
          fail 'The following depot(s) are required and were found to be missing: ' + missing.join(', ')
        end
      end

      # run pre-flight checks for:
      #  * both //.git-fusion and any referenced depots exist
      #  * Git Fusion repo ID is not already in use (no p4gf_config for the specified repo ID)
      # if any of the above conditions are not met, an exception is thrown
      def save_preflight(connection)
        # ensure both //.git-fusion and target depots exist
        ensure_depots_exist(connection)

        # ensure there isn't already a Git Fusion repo with our ID
        if perforce_path_exists?(perforce_p4gf_config_path, connection)
          fail "A Git Fusion repository already exists with the name (#{repo_name}). " \
               'You can import the existing Git Fusion repository into a new project.'
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

      def config=(config)
        self.class.validate_config(config)
        @config = config
      end

      def branch_mappings=(branch_mappings)
        self.class.validate_branch_mappings(branch_mappings)
        @branch_mappings = branch_mappings
      end

      def config(*args)
        if args.length > 0
          self.config = args[0]
          return self
        end
        @config
      end

      def repo_name(*args)
        if args.length > 0
          self.repo_name = args[0]
          return self
        end
        @repo_name
      end

      def branch_mappings(*args)
        if args.length > 0
          self.branch_mappings = args[0]
          return self
        end
        @branch_mappings
      end

      def depot_branch_creation(*args)
        if args.length > 0
          self.depot_branch_creation = args[0]
          return self
        end
        @depot_branch_creation
      end

      def description(*args)
        if args.length > 0
          self.description = args[0]
          return self
        end
        @description
      end
    end
  end
end
