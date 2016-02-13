require_relative '../../../spec_helper'

describe PerforceSwarm::GitFusion::RepoCreator do
  EXPECTED_EXCEPTION ||= PerforceSwarm::GitFusion::RepoCreatorError

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
    @connection.input = @connection.run('user', '-o', 'p4test').last
    @connection.run('user', '-i')
    @connection.login
  end

  after(:each) do
    @connection.disconnect if @connection
    FileUtils.remove_entry_secure @p4root
  end

  describe :validate_config do
    it 'raises an exception when the config is invalid' do
      [nil,
       {},
       { 'foo' => 'bar' },
       { 'enabled' => true },
       { 'local' => { 'url' => 'foo@bar' } }
      ].each do |config|
        expect do
          PerforceSwarm::GitFusion::RepoCreator.validate_config(config)
        end.to raise_error(EXPECTED_EXCEPTION), config.inspect
      end
    end

    it 'does not raise an exception when the config is valid with and without auto_create elements' do
      config = @base_config.clone.entry
      PerforceSwarm::GitFusion::RepoCreator.validate_config(config)
      config['auto_create'] = { 'path_template' => '//gitswarm/{namespace}/{project-path}',
                                'repo_name_template' => '{namespace}-{project-path}' }
      PerforceSwarm::GitFusion::RepoCreator.validate_config(config)
    end
  end

  describe :perforce_path_exists? do
    it 'returns true if there is content at the specified depot path' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      # create the required depot
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'gitswarm')

      # add a file to the depot path where we'll be checking
      @connection.with_temp_client do |tmpdir|
        file = File.join(tmpdir, 'gitswarm', 'projects', 'my-project', 'test-file.txt')
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, 'Foo bar!')
        @connection.run('reconcile', file)
        @connection.run('submit', '-d', 'Adding temporary file.')
      end

      # perform the check
      expect(creator.perforce_path_exists?('//gitswarm/projects/my-project/test-file.txt', @connection)).to be_truthy
      expect(creator.perforce_path_exists?('//gitswarm/projects/does-not-exist.txt', @connection)).to be_falsey
    end

    it 'returns false if there is no content at the specified depot path' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      expect(creator.perforce_path_exists?(creator.perforce_p4gf_config_path, @connection)).to be_falsey
    end
  end

  describe :validate_depots do
    it 'raises an exception if the depot branch depot and Git Fusion depots are both missing' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      creator.depot_branch_creation('//nonexistent/foo/{git_branch_name}')
      expect { creator.validate_depots(@connection) }.to raise_error(RuntimeError)
    end

    it 'raises an exception if the depot branch creation depot is present, but the Git Fusion depot is missing' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'gitswarm')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      creator.depot_branch_creation('//gitswarm/foo/{git_branch_name}')
      expect { creator.validate_depots(@connection) }.to raise_error(RuntimeError)
    end

    it 'raises an exception if the Git Fusion depot is present, but the depot branch creation depot is missing' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, '.git-fusion')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      creator.depot_branch_creation('//gitswarm/foo/{git_branch_name}')
      expect { creator.validate_depots(@connection) }.to raise_error(RuntimeError)
    end

    it 'does not raise an exception if both the depot branch creation depot and Git Fusion depots are present' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, '.git-fusion')
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'gitswarm')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      creator.depot_branch_creation('//gitswarm/foo/{git_branch_name}')
      expect { creator.validate_depots(@connection) }.to_not raise_error
    end

    it 'does not raise an exception if the depots specified in the branch mapping exist, raising if they do not' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, '.git-fusion')
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'gitswarm')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      creator.depot_branch_creation('//gitswarm/foo/{git_branch_name}')
      creator.branch_mappings('branch1' => '//depot1/foo', 'branch2' => '//depot1/bar')

      # depot1 does not exist yet, but is specified in the branch mapping
      expect { creator.validate_depots(@connection) }.to raise_error(RuntimeError)

      # create the depot and re-check
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'depot1')
      expect { creator.validate_depots(@connection) }.to_not raise_error
    end

    # streams tests
    it 'raises an exception if more than one streams depot is referenced in the branch mappings' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, '.git-fusion')
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'stream1', 'Type' => 'stream')
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'stream2', 'Type' => 'stream')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      creator.branch_mappings('branch1' => '//stream1/foo', 'branch2' => '//stream2/bar')
      expect { creator.validate_depots(@connection) }.to raise_error(RuntimeError)
    end

    it 'raises an exception if a mix of streams and non-streams depots are referenced in the branch mappings' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, '.git-fusion')
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'stream1', 'Type' => 'stream')
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'depot2')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      creator.branch_mappings('branch1' => '//stream1/foo', 'branch2' => '//depot1/bar')
      expect { creator.validate_depots(@connection) }.to raise_error(RuntimeError)
    end

    it 'does not raise an exception if the same streams depot is used for all branch mappings' do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(@base_config)
      PerforceSwarm::P4::Spec::Depot.create(@connection, '.git-fusion')
      PerforceSwarm::P4::Spec::Depot.create(@connection, 'stream1', 'Type' => 'stream')
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-project')
      creator.branch_mappings('branch1' => '//stream1/foo', 'branch2' => '//stream1/bar')
      expect { creator.validate_depots(@connection) }.to_not raise_error
    end
  end

  describe :p4gf_config do
    let(:config) do
      @base_config.clone
    end

    before do
      allow_any_instance_of(PerforceSwarm::GitlabConfig).to receive(:git_fusion).and_return(config)
    end

    it 'raises an exception if not branch mappings are specified' do
      creator = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-awesome-project')
      expect { creator.p4gf_config }.to raise_error(EXPECTED_EXCEPTION)
    end

    it 'can generate a config file with multiple branches and no depot branch creation' do
      branch_mapping = { 'branch1' => '//depot1/foo', 'branch2' => '//depot1/bar', 'branch3' => '//depot2/foo' }
      creator        = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-awesome-project', branch_mapping)
      expected = <<eos
[@repo]
description = Repo automatically created by GitSwarm.
enable-git-submodules = yes
enable-git-merge-commits = yes
enable-git-branch-creation = yes
ignore-author-permissions = yes

[branch1]
view = "//depot1/foo/..." ...
git-branch-name = branch1

[branch2]
view = "//depot1/bar/..." ...
git-branch-name = branch2

[branch3]
view = "//depot2/foo/..." ...
git-branch-name = branch3
eos
      expect(creator.p4gf_config).to eq(expected)
    end

    it 'can generate a config file with multiple branches and depot branch creation configured' do
      branch_mapping = { 'branch1' => '//depot1/foo', 'branch2' => '//depot1/bar', 'branch3' => '//depot2/foo' }
      creator        = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-awesome-project', branch_mapping)
      creator.depot_branch_creation('//gitswarm/projects/root/my-awesome-project/{git_branch_name}')
      expected = <<eos
[@repo]
description = Repo automatically created by GitSwarm.
enable-git-submodules = yes
enable-git-merge-commits = yes
enable-git-branch-creation = yes
ignore-author-permissions = yes
depot-branch-creation-depot-path = //gitswarm/projects/root/my-awesome-project/{git_branch_name}
depot-branch-creation-enable = all

[branch1]
view = "//depot1/foo/..." ...
git-branch-name = branch1

[branch2]
view = "//depot1/bar/..." ...
git-branch-name = branch2

[branch3]
view = "//depot2/foo/..." ...
git-branch-name = branch3
eos
      expect(creator.p4gf_config).to eq(expected)
    end

    it 'generates a config file with multiple branches and a changed description' do
      branch_mapping = { 'branch1' => '//depot1/foo' }
      creator        = PerforceSwarm::GitFusion::RepoCreator.new('foo', 'my-awesome-project', branch_mapping)
      creator.description('Extra description parts.')
      expected = <<eos
[@repo]
description = Repo automatically created by GitSwarm. Extra description parts.
enable-git-submodules = yes
enable-git-merge-commits = yes
enable-git-branch-creation = yes
ignore-author-permissions = yes

[branch1]
view = "//depot1/foo/..." ...
git-branch-name = branch1
eos
      expect(creator.p4gf_config).to eq(expected)
    end
  end
end
