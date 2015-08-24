require 'fileutils'

module PerforceSwarm
  class RepoCreatorError < StandardError
  end

  class ConfigValidationError < RepoCreatorError
  end

  class RepoCreator
    VALID_NAME_REGEX = /^([A-Za-z0-9_@\/\:\-])+$/

    attr_accessor :description
    attr_reader :path_template, :repo_name_template, :config

    def self.validate_config(config)
      # we need at the very least have a config, an auto_create_path and auto_create_repo_name
      unless config.is_a?(PerforceSwarm::GitFusion::ConfigEntry)
        fail ConfigValidationError, '"config" must be a ConfigEntry'
      end

      # validate path and repo name templates
      unless RepoCreator.valid_path_template?(config.auto_create['path_template'])
        fail ConfigValidationError, 'Auto create path template is missing or invalid.'
      end

      unless RepoCreator.valid_repo_name_template?(config.auto_create['repo_name_template'])
        fail ConfigValidationError, 'Auto create repo name template is missing or invalid.'
      end
    end

    def self.valid_path_template?(path)
      RepoCreator.valid_template?(path) && path.start_with?('//')
    end

    def self.valid_repo_name_template?(name)
      RepoCreator.valid_template?(name)
    end

    # generic function to validate either a namespace or project-path template
    def self.valid_template?(template)
      template.is_a?(String) &&
        template.include?('{project-path}') &&
        template.include?('{namespace}')
    end

    def initialize(id, namespace = nil, project_path = nil)
      # config validation happens on assignment
      self.config         = PerforceSwarm::GitlabConfig.new.git_fusion.entry(id)
      self.namespace      = namespace
      self.project_path   = project_path
      @path_template      = @config.auto_create['path_template']
      @repo_name_template = @config.auto_create['repo_name_template']
    end

    # returns the depot path that Git Fusion should use to store a project's branches and files
    def depot_path
      valid_variables? && valid_path_template?

      # render the path template
      render_template(path_template)
    end

    # returns the depot portion of the generated depot_path
    def project_depot
      path = depot_path
      path.gsub(%r{//([^/]+).*$}, '\1')
    end

    # returns the repo name that Git Fusion should use
    def repo_name
      valid_variables? && valid_repo_name_template?

      # render the name template
      render_template(repo_name_template)
    end

    def full_description
      'Repo automatically created by GitSwarm.' + (@description && !@description.empty? ? ' ' + @description : '')
    end

    # returns the relative path (directory only) to the p4gf_config file that we need to create for the current repo
    def p4gf_config_path
      "repos/#{repo_name}/p4gf_config"
    end

    # generates the p4gf_config file that should be checked into Perforce under
    # //.git-fusion/repos/repo_name/p4gf_config
    def p4gf_config
      <<eof
[@repo]
enable-git-submodules = yes
description = #{full_description}
enable-git-merge-commits = yes
enable-git-branch-creation = yes
ignore-author-permissions = yes
depot-branch-creation-depot-path = #{depot_path}/{git_branch_name}
depot-branch-creation-enable = all

[master]
view = #{depot_path}/master/... ...
git-branch-name = master
eof
    end

    # attempt to add our p4gf_config file for Git Fusion
    def create_git_fusion_repo
      # connect to p4d and login
      @p4 ||= PerforceSwarm::P4Connection.new(@config)
      @p4.login

      # ensure the depots exist - both the //.git-fusion one as well as the one the user wants to create their project
      depot = project_depot
      fail 'The //.git-fusion depot does not exist and is required.' unless depot_exists?('.git-fusion')
      fail "The depot specified for project mirroring (#{depot}) does not exist." unless depot_exists?(depot)

      # generate our file and attempt to add it
      @p4.with_temp_client do |tmpdir|
        begin
          path      = '//.git-fusion/' + p4gf_config_path
          p4gf_file = File.join(tmpdir, '.git-fusion', p4gf_config_path)
          FileUtils.mkdir_p(File.dirname(p4gf_file))
          File.write(p4gf_file, p4gf_config)
          add_output = @p4.run('add', path).shift
          if add_output.is_a?(String) && add_output.end_with?(" - can't add existing file")
            # revert and delete change
            # @TODO: there doesn't appear to be a change to revert?
            fail FileAlreadyExists, "Looks like #{path} already exists."
          end

          @p4.run('submit', '-d', "'GitSwarm adding a Git Fusion repo.'")
        rescue P4Exception => e
          # @TODO: are there any specific errors we want to trap and deal with here?
          raise e
        end
      end
    end

    def depot_exists?(depot_name)
      @p4  ||= PerforceSwarm::P4Connection.new(@config)
      @p4.login

      depots = @p4.run('depots')
      depots.each do |depot|
        next unless depot['map'].start_with?("#{depot_name}/...")
        return true
      end
      false
    end

    def config=(config)
      RepoCreator.validate_config(config)
      @config    = config
      @repo_path = config['auto_create_path']
      @repo_name = config['auto_create_repo_name']
    end

    def namespace=(namespace)
      @namespace = git_fusion_escape_chars(namespace)
    end

    def project_path=(project_path)
      @project_path = git_fusion_escape_chars(project_path)
    end

    # Git Fusion needs : and / escaped in repo names
    def git_fusion_escape_chars(string)
      return string unless string && string.is_a?(String)
      string.gsub(/\:/, '_0xC_').gsub(/\//, '_0xS_')
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

    # ensures that we have a valid namespace and project-path so we know we're good to go with variable substitutions
    def valid_variables?
      unless project_path && project_path.is_a?(String) && !project_path.empty?
        fail RepoCreatorError, 'Specified project-path must be non-empty.'
      end

      unless namespace && namespace.is_a?(String) && !namespace.empty?
        fail RepoCreatorError, 'Specified namespace must be non-empty.'
      end

      unless namespace =~ VALID_NAME_REGEX
        fail RepoCreatorError, "Specified namespace is invalid: '#{namespace}'."
      end

      unless project_path =~ VALID_NAME_REGEX
        fail RepoCreatorError, "Specified project-path is invalid: '#{project_path}'."
      end
    end

    def valid_path_template?
      unless RepoCreator.valid_path_template?(path_template)
        fail ConfigValidationError, 'Auto create path template is missing or invalid.'
      end
    end

    def valid_repo_name_template?
      unless RepoCreator.valid_repo_name_template?(repo_name_template)
        fail RepoCreatorError, 'Auto create repo name template is missing or invalid.'
      end
    end

    def render_template(template)
      template.gsub(/\{project\-path\}/, project_path).gsub(/\{namespace\}/, namespace)
    end
  end
end
