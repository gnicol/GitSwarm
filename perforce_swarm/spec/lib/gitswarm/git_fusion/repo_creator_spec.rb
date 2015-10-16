require_relative '../../../spec_helper'

describe PerforceSwarm::GitFusion::RepoCreator do
  DEFAULT_REPO_NAME_TEMPLATE = 'gitswarm-{namespace}-{project-path}'
  EXPECTED_EXCEPTION         = PerforceSwarm::GitFusion::RepoCreatorError

  before(:all) do
    @p4d = `PATH=$PATH:/opt/perforce/sbin which p4d`.strip
  end

  before(:each) do
    @p4root      = Dir.mktmpdir
    @base_config = ::PerforceSwarm::GitFusion::Config.new(
        'enabled' => true,
        'global' => {},
        'foo' => {
          'url'  => 'foo@unknown-host',
          'user' => 'p4test',
          'perforce' => {
            'port' => "rsh:#{@p4d} -r #{@p4root} -i -q"
          }
        }
    )
    @connection = PerforceSwarm::P4::Connection.new(@base_config.entry('foo'), @p4root)
    @auto_provision_config = @base_config.clone
    @auto_provision_config['foo']['auto_create'] = {
      'path_template' => '//gitswarm/projects/{namespace}/{project-path}',
      'repo_name_template' => DEFAULT_REPO_NAME_TEMPLATE
    }
  end

  after(:each) do
    @connection.disconnect if @connection
    FileUtils.remove_entry_secure @p4root
  end

  describe :validate_config do
    it 'raises an exception when the config is invalid' do
      entry                = @base_config.entry
      entry['auto_create'] = { 'path_template' => 'path', 'repo_name_template' => 'name' }
      [nil,
       {},
       { 'foo' => 'bar' },
       { 'enabled' => true },
       { 'default' => { 'url' => 'foo@bar' } },
       @base_config.clone.entry,
       entry
      ].each do |config|
        expect do
          PerforceSwarm::GitFusion::RepoCreator.validate_config(config)
        end.to raise_error(EXPECTED_EXCEPTION), config.inspect
      end
    end

    it 'raises an exception when the config has invalid values for auto_create path/repo_name templates' do
      [{ 'auto_create' => { 'path_template' => 0, 'repo_name_template' => '' } },
       { 'auto_create' => { 'path_template' => '', 'repo_name_template' => 'name' } },
       { 'auto_create' => { 'path_template' => 'path', 'repo_name_template' => 'name' } },
       { 'auto_create' => { 'path_template' => {}, 'repo_name_template' => 'name' } },
       { 'auto_create' => { 'path_template' => '//some/path/{project-path}', 'repo_name_template' => 'name' } },
       { 'auto_create' => { 'path_template' => '//some/path/{project-path}', 'repo_name_template' => ['name'] } },
       { 'auto_create' => { 'path_template' => '//static/path', 'repo_name_template' => 'name' } },
       { 'auto_create' => { 'path_template' => '//some/{namespace}/{project-path}', 'repo_name_template' => 'name' } },
       { 'auto_create' => { 'path_template' => '//some/{namespace}/{project-path}', 'repo_name_template' => ['nom'] } },
       { 'auto_create' => { 'path_template' => '//static/path', 'repo_name_template' => 'name' } }
      ].each do |config|
        entry                = @base_config.entry
        entry['auto_create'] = config
        expect do
          PerforceSwarm::GitFusion::RepoCreator.validate_config(entry)
        end.to raise_error(EXPECTED_EXCEPTION), config.inspect
      end
    end

    it 'does not raise an exception when the config is valid' do
      config = @base_config.clone.entry
      config['auto_create'] = { 'path_template' => '//gitswarm/{namespace}/{project-path}',
                                'repo_name_template' => DEFAULT_REPO_NAME_TEMPLATE }
      PerforceSwarm::GitFusion::RepoCreator.validate_config(config)
    end
  end

  describe :depot_path do
    it 'raises an exception if we attempt to generate a depot path using variables that are not configured' do
      config = @base_config.clone
      config['foo']['auto_create'] = { 'path_template' => '//gitswarm/projects/{namespace}/{project-path}',
                                       'repo_name_template' => DEFAULT_REPO_NAME_TEMPLATE }
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo')
      expect { creator.depot_path }.to raise_error(EXPECTED_EXCEPTION), creator.inspect
    end

    it 'raises an exception if we attempt to generate a depot path using variables with invalid characters' do
      config = @base_config.clone
      config['foo']['auto_create'] = { 'path_template' => '//gitswarm/projects/{namespace}/{project-path}',
                                       'repo_name_template' => DEFAULT_REPO_NAME_TEMPLATE }
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', '!namespace', 'valid-path')
      expect { creator.depot_path }.to raise_error(EXPECTED_EXCEPTION)
      expect { creator.namespace('ns').project_path('').depot_path }.to raise_error(EXPECTED_EXCEPTION)
    end

    it 'generates the correct depot path when given all required variables' do
      config = @base_config.clone
      config['foo']['auto_create'] = { 'path_template' => '//gitswarm/projects/{namespace}/{project-path}',
                                       'repo_name_template' => DEFAULT_REPO_NAME_TEMPLATE }
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-project')
      expect(creator.depot_path).to eq('//gitswarm/projects/root/my-project')
    end
  end

  describe :p4gf_config_exists? do
    it 'raises an exception if we attempt to detect a p4gf_config file using variables that are not configured' do
      config = @base_config.clone
      config['foo']['auto_create'] = { 'path_template' => '//gitswarm/projects/{namespace}/{project-path}',
                                       'repo_name_template' => DEFAULT_REPO_NAME_TEMPLATE }
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo')
      expect { creator.p4gf_config_exists? }.to raise_error(EXPECTED_EXCEPTION), creator.inspect
    end

    it 'raises an exception if we attempt to detect a p4gf_config file using invalid variable values' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', '!namespace', 'valid-path')
      expect { creator.p4gf_config_exists? }.to raise_error(EXPECTED_EXCEPTION)
    end

    it 'returns true if there is already a p4gf_config file for the project we are trying to create' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-project')
      # create the required depot
      PerforceSwarm::P4::Spec::Depot.create(@connection, '.git-fusion')

      # add a file to the depot path where we'll be checking
      @connection.with_temp_client do |tmpdir|
        file = creator.p4gf_config_path(tmpdir)
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, 'This could be a valid p4gf_config file, but who cares.')
        @connection.run('reconcile', file)
        @connection.run('submit', '-d', 'Adding p4gf_config file.')
      end

      # perform the check
      expect(creator.p4gf_config_exists?).to be_truthy
    end

    it 'returns false if there is no content at the generated depot path' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-project')
      expect(creator.p4gf_config_exists?).to be_falsey
    end
  end

  describe :depot_path_content? do
    it 'raises an exception if we attempt to see if there is content using variables that are not configured' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo')
      expect { creator.depot_path_content? }.to raise_error(EXPECTED_EXCEPTION), creator.inspect
    end

    it 'raises an exception if we attempt to see if there is content using invalid variable values' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', '!namespace', 'valid-path')
      expect { creator.depot_path_content? }.to raise_error(EXPECTED_EXCEPTION)
    end

    it 'returns true if there is content at the generated depot path' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-project')
      # create the required depot
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'gitswarm')

      # add a file to the depot path where we'll be checking
      @connection.with_temp_client do |tmpdir|
        file = File.join(tmpdir, 'gitswarm', 'projects', 'root', 'my-project', 'test-file.txt')
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, 'Foo bar!')
        @connection.run('reconcile', file)
        @connection.run('submit', '-d', 'Adding temporary file.')
      end

      # perform the check
      expect(creator.depot_path_content?).to be_truthy
    end

    it 'returns false if there is no content at the generated depot path' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-project')
      expect(creator.depot_path_content?).to be_falsey
    end
  end

  describe :ensure_depots_exist do
    it 'raises an exception if the project and Git Fusion depots are both missing' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-project')
      expect { creator.ensure_depots_exist }.to raise_error(RuntimeError)
    end

    it 'raises an exception if the project depot is present, but the Git Fusion depot is missing' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'gitswarm')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-project')
      expect { creator.ensure_depots_exist }.to raise_error(RuntimeError)
    end

    it 'raises an exception if the Git Fusion depot is present, but the project depot is missing' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, '.git-fusion')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-project')
      expect { creator.ensure_depots_exist }.to raise_error(RuntimeError)
    end

    it 'returns true if both the project and Git Fusion depots are present' do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: @auto_provision_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, '.git-fusion')
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'gitswarm')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-project')
      expect { creator.ensure_depots_exist }.to_not raise_error(RuntimeError)
    end
  end

  describe :p4gf_config do
    let(:config) do
      config = @base_config.clone
      config['global']['auto_create'] = { 'path_template' => '//gitswarm/projects/{namespace}/{project-path}',
                                          'repo_name_template' => DEFAULT_REPO_NAME_TEMPLATE }
      config
    end

    before do
      PerforceSwarm::GitlabConfig.any_instance.stub(git_fusion: config)
    end

    it 'generates a config file with the correct depot path and description' do
      expected = <<eos
[@repo]
description = Repo automatically created by GitSwarm.
enable-git-submodules = yes
enable-git-merge-commits = yes
enable-git-branch-creation = yes
ignore-author-permissions = yes
depot-branch-creation-depot-path = //gitswarm/projects/root/my-awesome-project/{git_branch_name}
depot-branch-creation-enable = all

[master]
view = "//gitswarm/projects/root/my-awesome-project/master/..." ...
git-branch-name = master
eos
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-awesome-project')
      expect(creator.p4gf_config).to eq(expected)
      expected = <<eos
[@repo]
description = Repo automatically created by GitSwarm. Extra description parts.
enable-git-submodules = yes
enable-git-merge-commits = yes
enable-git-branch-creation = yes
ignore-author-permissions = yes
depot-branch-creation-depot-path = //gitswarm/projects/root/my-awesome-project/{git_branch_name}
depot-branch-creation-enable = all

[master]
view = "//gitswarm/projects/root/my-awesome-project/master/..." ...
git-branch-name = master
eos
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-awesome-project')
      expect(creator.description('Extra description parts.').p4gf_config).to eq(expected)
      expected = <<eos
[@repo]
description = Repo automatically created by GitSwarm. With newlines. In it.
enable-git-submodules = yes
enable-git-merge-commits = yes
enable-git-branch-creation = yes
ignore-author-permissions = yes
depot-branch-creation-depot-path = //gitswarm/projects/root/my-awesome-project/{git_branch_name}
depot-branch-creation-enable = all

[master]
view = "//gitswarm/projects/root/my-awesome-project/master/..." ...
git-branch-name = master
eos
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'root', 'my-awesome-project')
      expect(creator.description("\nWith newlines.\nIn it.").p4gf_config).to eq(expected)
      # TODO: add more tests for things like weird UTF-8 characters and the like
    end
  end
end
