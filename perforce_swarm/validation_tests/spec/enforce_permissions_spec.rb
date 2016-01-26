require 'spec_helper'

require_relative '../lib/pages/login_page'
require_relative '../lib/pages/logged_in_page'
require_relative '../lib/user'
require_relative '../lib/project'

describe 'EnforcePermissionsTests', browser: true, EnforcePermission: true do
  PRIVATE = 'private'
  PUBLIC  = 'public'

  # before(:all) does the setup just once before the entire group
  # https://www.relishapp.com/rspec/rspec-core/v/2-2/docs/hooks/before-and-after-hooks
  before(:all) do
    # control whether setup /teardown is performed. Values in config.yml will configure this
    # Allows us to do a single setup and reuse it for test development to save time
    # You must provide run_id if you skip setup or things won't work properly
    @setup    = CONFIG.get(CONFIG::SKIP_SETUP)    ? false : true
    @teardown = CONFIG.get(CONFIG::SKIP_TEARDOWN) ? false : true
    @run_id   = CONFIG.get(CONFIG::RUN_ID)        || unique_string

    LOG.log('Skipping setup due to setting') unless @setup
    LOG.log("run_id for this run is #{@run_id}")

    @groupname = @run_id

    # These two config properties are required for these tests - fail immediately unless they are configured

    [CONFIG::SECURE_GF, CONFIG::SECURE_GF_DEPOT_ROOT].each do |property|
      fail("Required config.yml property does not exist: #{property}") unless CONFIG.get(property)
    end

    @p4_admin_dir = Dir.mktmpdir('enf-perms-p4-', tmp_client_dir)

    LOG.log 'p4 admin dir = ' + @p4_admin_dir

    @depot_root = CONFIG.get(CONFIG::SECURE_GF_DEPOT_ROOT)
    @p4_admin = P4Helper.new(CONFIG.get(CONFIG::P4_PORT),
                             CONFIG.get(CONFIG::P4_USER),
                             CONFIG.get(CONFIG::P4_PASSWORD),
                             @p4_admin_dir,
                             @depot_root+'...')

    @git_fusion_helper = GitFusionHelper.new(CONFIG.get(CONFIG::P4_PORT),
                                             CONFIG.get(CONFIG::P4_USER),
                                             CONFIG.get(CONFIG::P4_PASSWORD))

    @gs_api = GitSwarmAPIHelper.new(CONFIG.get(CONFIG::GS_URL),
                                    CONFIG.get(CONFIG::GS_USER),
                                    CONFIG.get(CONFIG::GS_PASSWORD))

    @read_all_write_all          = Project.new(@run_id + '_read_all_write_all', @run_id)
    @read_all_write_partial      = Project.new(@run_id + '_read_all_write_partial', @run_id)
    @read_all_write_none         = Project.new(@run_id + '_read_all_write_none', @run_id)
    @read_partial                = Project.new(@run_id + '_read_partial', @run_id)
    @read_none                   = Project.new(@run_id + '_read_none', @run_id)
    @projects                    = [@read_all_write_all,
                                    @read_all_write_partial,
                                    @read_all_write_none,
                                    @read_partial,
                                    @read_none]
    @projects.each do |project|
      LOG.log("Project for test run : #{project.name}")
    end

    @user_root                        = User.new(CONFIG.get(CONFIG::GS_USER),
                                                 CONFIG.get(CONFIG::GS_PASSWORD),
                                                 'admin@example.com')
    # in both p4 and gs and has access in both places
    @user_gs_master_p4_access         = User.new(@run_id + '_gs_master_p4_access')
    # in both p4 and gs and has access in p4, but only developer access in gs (cannot merge to preotected branches)
    @user_gs_dev_p4_access            = User.new(@run_id + '_gs_dev_p4_access')
    # in both p4 and gs and has access in p4 only
    @user_gs_noaccess_p4_access       = User.new(@run_id + '_gs_noaccess_p4_access')
    # in both p4 and gs and has access in gs only
    @user_gs_master_p4_noaccess       = User.new(@run_id + '_gs_master_p4_noaccess')
    # only in gs
    @user_gs_master_p4_notexist       = User.new(@run_id + '_gs_access_p4_notexist')
    @users                            = [@user_gs_master_p4_access,
                                         @user_gs_dev_p4_access,
                                         @user_gs_noaccess_p4_access,
                                         @user_gs_master_p4_noaccess,
                                         @user_gs_master_p4_notexist]
    @users.each do |user|
      LOG.log("User for test run    : #{user.name}")
    end

    @p4_admin.connect
    # save the initial protects to reset to after
    @initial_protects = @p4_admin.protects

    private_dir = "/master/#{PRIVATE}"
    public_dir = "/master/#{PUBLIC}"

    if @setup
      LOG.log('Creating repo structure in p4')
      @projects.each do |dir|
        file = create_file("#{@p4_admin_dir}/#{@run_id}/#{dir.name}#{private_dir}", 'file.txt')
        @p4_admin.add(file)
        file = create_file("#{@p4_admin_dir}/#{@run_id}/#{dir.name}#{public_dir}", 'file.txt')
        @p4_admin.add(file)
      end
      @p4_admin.submit

      LOG.log('Creating Git Fusion repos')
      @projects.each do |proj|
        LOG.debug(proj.name)
        @git_fusion_helper.make_new_gf_repo(proj.name, "#{@depot_root}#{@run_id}/#{proj.name}")
      end
      @git_fusion_helper.apply_gf_global_config('read-permission-check' => 'user')

      LOG.log('Setting up P4 users and protections')
      @p4_admin.remove_protects('*') # Explicitly remove any wildcard permissions

      # Add write protect for unknown_git. Allows 'root' to push anywhere as the email addresss doesn't match
      @p4_admin.add_write_protects('unknown_git', "#{@depot_root}#{@run_id}/...")

      @p4_admin.create_user(@user_gs_master_p4_noaccess.name,
                            @user_gs_master_p4_noaccess.password,
                            @user_gs_master_p4_noaccess.email)

      [@user_gs_master_p4_access, @user_gs_noaccess_p4_access, @user_gs_dev_p4_access].each do |usr|
        # create user
        @p4_admin.create_user(usr.name, usr.password, usr.email)
        # read_all_write_all
        @p4_admin.add_write_protects(usr.name, "#{@depot_root}#{@run_id}/#{@read_all_write_all.name}/...")
        # read_all_write_partial
        @p4_admin.add_read_protects(usr.name, "#{@depot_root}#{@run_id}/#{@read_all_write_partial.name}/...")
        @p4_admin.add_write_protects(usr.name,
                                     "#{@depot_root}#{@run_id}/#{@read_all_write_partial.name}#{public_dir}/...")
        # read_all_write_none
        @p4_admin.add_read_protects(usr.name,  "#{@depot_root}#{@run_id}/#{@read_all_write_none.name}/...")
        # read_partial
        @p4_admin.add_read_protects(usr.name,  "#{@depot_root}#{@run_id}/#{@read_partial.name}#{public_dir}/...")
      end

      LOG.log('Creating GitSwarm users, and group')
      @gs_api.create_group(@groupname)
      @users.each do |usr|
        @gs_api.create_user(usr.name, usr.password, usr.email)
        # gs_naccess should not be in the group
        @gs_api.add_user_to_group(usr.name, @groupname) unless
            (usr == @user_gs_noaccess_p4_access) || (usr == @user_gs_dev_p4_access)
      end
      @gs_api.add_user_to_group(@user_gs_dev_p4_access.name, @groupname, GitSwarmAPIHelper::DEVELOPER)

      LOG.log('Creating GitSwarm projects')
      @driver = Browser.driver
      logged_in_page = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(CONFIG.get(CONFIG::GS_USER),
                                                                                CONFIG.get(CONFIG::GS_PASSWORD))
      @projects.each do |project|
        cp = logged_in_page.goto_create_project_page
        cp.project_name(project.name)
        cp.namespace(@groupname)
        cp.select_server(CONFIG.get(CONFIG::SECURE_GF))
        cp.select_repo(project.name)
        cp.select_private
        cp.create_project_and_wait_for_clone
      end
      logged_in_page.logout
      Browser.reset!
    end # if @setup

    @projects.each do |project|
      project.http_url= @gs_api.get_project_info(project.name)[GitSwarmAPIHelper::HTTP_URL]
    end
  end

  # after(:all) does the teardown just once after the entire group
  after(:all) do
    LOG.log('Removing tmp dirs')
    FileUtils.rm_r(@p4_admin_dir)

    LOG.log('Skipping teardown due to setting') unless @teardown
    if @teardown
      begin
        LOG.log('Deleting created users')
        @users.each do |usr|
          @p4_admin.delete_user(usr.name) unless usr == @user_gs_master_p4_notexist
        end
        @p4_admin.disconnect

        @git_fusion_helper.apply_gf_global_config('read-permission-check' => '')

        @projects.each do |project|
          @gs_api.delete_project(project.name)
        end
        @users.each do |user|
          @gs_api.delete_user(user.name)
        end
        @gs_api.delete_group(@groupname)
      rescue => e
        LOG.log('Exception raised in after block : '+e.message)
        LOG.log(e.backtrace.join('\n'))
      end
    end
  end

  #
  # GF repo visibility in GitSwarm as restricted by Perforce permissions
  #

  describe 'A user with full read permissions in perforce' do
    it 'should be allowed to see all GF repos when creating gs projects' do
      available_repos = list_repos_for_user(@user_root)
      LOG.log(available_repos.inspect)
      expect(available_repos).to include(@read_all_write_all.name)
      expect(available_repos).to include(@read_all_write_partial.name)
      expect(available_repos).to include(@read_all_write_none.name)
      expect(available_repos).to include(@read_partial.name)
      expect(available_repos).to include(@read_none.name)
    end
  end

  describe 'A user with limited read permissions in perforce' do
    it 'should be allowed to see only GF repos with full read permission when creating gs projects' do
      available_repos = list_repos_for_user(@user_gs_master_p4_access)
      LOG.log(available_repos.inspect)
      expect(available_repos).to include(@read_all_write_all.name)
      expect(available_repos).to include(@read_all_write_partial.name)
      expect(available_repos).to include(@read_all_write_none.name)
      expect(available_repos).to_not include(@read_partial.name)
      expect(available_repos).to_not include(@read_none.name)
    end
  end

  describe 'A user with no read permissions in perforce' do
    it 'should not be allowed to see any GF repos when creating gs projects' do
      available_repos = list_repos_for_user(@user_gs_master_p4_noaccess)
      LOG.log(available_repos.inspect)
      expect(available_repos).to_not include(@read_all_write_all.name)
      expect(available_repos).to_not include(@read_all_write_partial.name)
      expect(available_repos).to_not include(@read_all_write_none.name)
      expect(available_repos).to_not include(@read_partial)
      expect(available_repos).to_not include(@read_none.name)
    end
  end

  describe 'A user not in perforce' do
    it 'should not be allowed to see any GF repos when creating gs projects' do
      available_repos = list_repos_for_user(@user_gs_master_p4_notexist)
      LOG.log(available_repos.inspect)
      expect(available_repos).to_not include(@read_all_write_all.name)
      expect(available_repos).to_not include(@read_all_write_partial.name)
      expect(available_repos).to_not include(@read_all_write_none.name)
      expect(available_repos).to_not include(@read_partial.name)
      expect(available_repos).to_not include(@read_none.name)
    end
  end

  #
  # Project visibility in GitSwarm as restricted by Perforce permissions
  #

  describe 'A user with full read permissions in perforce' do
    it 'should be allowed to SEE all GS projects mirrored in perforce' do
      available_projects = list_projects_for_user(@user_root)
      LOG.log(available_projects.inspect)
      expect(available_projects).to include(@read_all_write_all.name)
      expect(available_projects).to include(@read_all_write_partial.name)
      expect(available_projects).to include(@read_all_write_none.name)
      expect(available_projects).to include(@read_partial.name)
      expect(available_projects).to include(@read_none.name)
    end
  end
  describe 'A user with limited read permissions in perforce' do
    it 'should be allowed to SEE only GS projects mirrored in perforce where they have read permission in perforce' do
      available_projects = list_projects_for_user(@user_gs_master_p4_access)
      LOG.log(available_projects.inspect)
      expect(available_projects).to include(@read_all_write_all.name)
      expect(available_projects).to include(@read_all_write_partial.name)
      expect(available_projects).to include(@read_all_write_none.name)
      expect(available_projects).to_not include(@read_partial.name)
      expect(available_projects).to_not include(@read_none.name)
    end
  end

  describe 'A user with no read permissions in perforce' do
    it 'should not be allowed to SEE any GS projects mirrored in perforce' do
      available_projects = list_projects_for_user(@user_gs_master_p4_noaccess)
      LOG.log(available_projects.inspect)
      expect(available_projects).to_not include(@read_all_write_all.name)
      expect(available_projects).to_not include(@read_all_write_partial.name)
      expect(available_projects).to_not include(@read_all_write_none.name)
      expect(available_projects).to_not include(@read_partial.name)
      expect(available_projects).to_not include(@read_none.name)
    end
  end

  describe 'A user not in perforce' do
    it 'should not be allowed to SEE any GS projects mirrored in perforce' do
      available_projects = list_projects_for_user(@user_gs_master_p4_notexist)
      LOG.log(available_projects.inspect)
      expect(available_projects).to_not include(@read_all_write_all.name)
      expect(available_projects).to_not include(@read_all_write_partial.name)
      expect(available_projects).to_not include(@read_all_write_none.name)
      expect(available_projects).to_not include(@read_partial.name)
      expect(available_projects).to_not include(@read_none.name)
    end
  end

  describe 'A user with no access to the GS project' do
    it 'should not be allowed to SEE any GS projects even if they have read access in perforce' do
      available_projects = list_projects_for_user(@user_gs_noaccess_p4_access)
      LOG.log(available_projects.inspect)
      expect(available_projects).to_not include(@read_all_write_all.name)
      expect(available_projects).to_not include(@read_all_write_partial.name)
      expect(available_projects).to_not include(@read_all_write_none.name)
      expect(available_projects).to_not include(@read_partial.name)
      expect(available_projects).to_not include(@read_none.name)
    end
  end

  #
  # Project clone through GitSwarm as restricted by Perforce permissions
  #

  describe 'A user with full read permissions in perforce' do
    it 'should be allowed to CLONE all GS projects mirrored in perforce' do
      expect(can_clone(@user_root, @read_all_write_all)).to be true
      expect(can_clone(@user_root, @read_all_write_partial)).to be true
      expect(can_clone(@user_root, @read_all_write_none)).to be true
      expect(can_clone(@user_root, @read_partial)).to be true
      expect(can_clone(@user_root, @read_none)).to be true
    end
  end

  describe 'A user with limited read permissions in perforce' do
    it 'should be allowed to CLONE only GS projects mirrored in perforce where they have read permission in perforce' do
      expect(can_clone(@user_gs_master_p4_access, @read_all_write_all)).to be true
      expect(can_clone(@user_gs_master_p4_access, @read_all_write_partial)).to be true
      expect(can_clone(@user_gs_master_p4_access, @read_all_write_none)).to be true
      expect(can_clone(@user_gs_master_p4_access, @read_partial)).to be false
      expect(can_clone(@user_gs_master_p4_access, @read_none)).to be false
    end
  end

  describe 'A user with no read permissions in perforce' do
    it 'should not be allowed to CLONE any GS projects mirrored in perforce' do
      expect(can_clone(@user_gs_master_p4_noaccess, @read_all_write_all)).to be false
      expect(can_clone(@user_gs_master_p4_noaccess, @read_all_write_partial)).to be false
      expect(can_clone(@user_gs_master_p4_noaccess, @read_all_write_none)).to be false
      expect(can_clone(@user_gs_master_p4_noaccess, @read_partial)).to be false
      expect(can_clone(@user_gs_master_p4_noaccess, @read_none)).to be false
    end
  end

  describe 'A user not in perforce' do
    it 'should not be allowed to CLONE any GS projects mirrored in perforce' do
      expect(can_clone(@user_gs_master_p4_notexist, @read_all_write_all)).to be false
      expect(can_clone(@user_gs_master_p4_notexist, @read_all_write_partial)).to be false
      expect(can_clone(@user_gs_master_p4_notexist, @read_all_write_none)).to be false
      expect(can_clone(@user_gs_master_p4_notexist, @read_partial)).to be false
      expect(can_clone(@user_gs_master_p4_notexist, @read_none)).to be false
    end
  end

  describe 'A user with no access to the GS project' do
    it 'should not be allowed to CLONE any GS projects even if they have read access in perforce' do
      expect(can_clone(@user_gs_noaccess_p4_access, @read_all_write_all)).to be false
      expect(can_clone(@user_gs_noaccess_p4_access, @read_all_write_partial)).to be false
      expect(can_clone(@user_gs_noaccess_p4_access, @read_all_write_none)).to be false
      expect(can_clone(@user_gs_noaccess_p4_access, @read_partial)).to be false
      expect(can_clone(@user_gs_noaccess_p4_access, @read_none)).to be false
    end
  end

  #
  # Project write/push through GitSwarm as restricted by Perforce permissions
  #

  describe 'A user with full write permissions in perforce' do
    it 'should be allowed to PUSH to anywhere in a GS project mirrored in perforce' do
      user = @user_root
      @projects.each do |project|
        expect(can_push(user, project, PUBLIC)).to be true
        expect(can_push(user, project, PRIVATE)).to be true
      end
    end
  end

  describe 'A user with partial write permissions in perforce' do
    it 'should be allowed to PUSH only to areas where they have write access in perforce' do
      user = @user_gs_master_p4_access
      expect(can_push(user, @read_all_write_all, PRIVATE)).to be true
      expect(can_push(user, @read_all_write_all, PUBLIC)).to be true
      expect(can_push(user, @read_all_write_partial, PRIVATE)).to be false
      expect(can_push(user, @read_all_write_partial, PUBLIC)).to be true
      expect(can_push(user, @read_all_write_none, PRIVATE)).to be false
      expect(can_push(user, @read_all_write_none, PUBLIC)).to be false
    end
  end

  describe 'A user with partial write permissions in perforce' do
    it 'should not be allowed to PUSH only if they dont have p4 write access to ALL files in a push' do
      user = @user_gs_master_p4_access
      Dir.mktmpdir(nil, tmp_client_dir) do |dir|
        git = GitHelper.http_helper(dir, @read_all_write_partial.http_url, user.name, user.password, user.email)
        git.clone # leave fail_on_error, this method should only be called for configurations with repo read permission
        git.fail_on_error=false
        create_file(File.join(dir, PUBLIC))  # add one file that should be pushable
        create_file(File.join(dir, PRIVATE)) # add one file that should NOT be pushable
        expect(git.add_commit_push).to be false
      end
    end
  end

  describe 'During a merge, a user with no write permissions in perforce' do
    it 'should have attempts to accept the merge fail, even if the author of the MR has full write permissions' do
      branch = "branch-#{unique_string}"
      mr_title = "Merge request for #{branch}"

      create_merge_request(@user_root, @read_all_write_none, branch, mr_title)
      lp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      loggedin_page = lp.login(@user_gs_master_p4_access.name, @user_gs_master_p4_access.password)
      mr_page = loggedin_page.goto_merge_request_page(@read_all_write_none.namespace,
                                                      @read_all_write_none.name,
                                                      mr_title)
      LOG.log('Merge the branch as user with no write permission')
      mr_page.accept_merge_request_expecting_failure
    end
  end

  describe 'During a merge, a user with partial write permissions in perforce' do
    it 'should have attempts to accept the merge fail, even if the author of the MR has full write permissions' do
      branch = "branch-#{unique_string}"
      mr_title = "Merge request for #{branch}"

      create_merge_request(@user_root, @read_all_write_partial, branch, mr_title)
      lp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      loggedin_page = lp.login(@user_gs_master_p4_access.name, @user_gs_master_p4_access.password)
      mr_page = loggedin_page.goto_merge_request_page(@read_all_write_partial.namespace,
                                                      @read_all_write_partial.name,
                                                      mr_title)
      LOG.log('Merge the branch as user with partial write permission')
      mr_page.accept_merge_request_expecting_failure
    end
  end

  describe 'During a merge, a user with full write permissions in perforce' do
    it 'should have attempts to accept the merge succeed' do
      branch = "branch-#{unique_string}"
      mr_title = "Merge request for #{branch}"

      create_merge_request(@user_root, @read_all_write_all, branch, mr_title)
      lp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      loggedin_page = lp.login(@user_gs_master_p4_access.name, @user_gs_master_p4_access.password)
      mr_page = loggedin_page.goto_merge_request_page(@read_all_write_all.namespace,
                                                      @read_all_write_all.name,
                                                      mr_title)
      LOG.log('Merge the branch as user without permission')
      mr_page.accept_merge_request
    end
  end

  describe 'During a merge, a user with full write permissions in perforce but only developer access in GitSwarm' do
    it 'should not be allowed to try to accept a merge request into master branch' do
      branch = "branch-#{unique_string}"
      mr_title = "Merge request for #{branch}"

      create_merge_request(@user_root, @read_all_write_all, branch, mr_title)
      lp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      loggedin_page = lp.login(@user_gs_dev_p4_access.name, @user_gs_dev_p4_access.password)
      mr_page = loggedin_page.goto_merge_request_page(@read_all_write_all.namespace,
                                                      @read_all_write_all.name,
                                                      mr_title)
      LOG.log('Expect the merge request to be \'Open\'')
      expect(mr_page.state).to eq(MergeRequestPage::OPEN)
      LOG.log('Expect there to be no \'accept merge request\' button')
      expect(mr_page.can_accept_merge).to be false
      LOG.log('Expect there to be a message telling you to ask someone with permission to do the merge')
      expect(mr_page.page_has_text('Ask someone with write access to this repository to merge this request')).to be true
    end
  end

  private

  def create_merge_request(user, project, branch, title)
    Dir.mktmpdir(nil, tmp_client_dir) do |dir|
      git = GitHelper.http_helper(dir, project.http_url, user.name, user.password, user.email)
      git.clone
      LOG.log("Branching new branch #{branch}")
      git.branch_and_checkout(branch)
      create_file(File.join(dir, PUBLIC))  # add one file that should be pushable
      create_file(File.join(dir, PRIVATE)) # add one file that should NOT be pushable
      LOG.log('Adding files to public and private parts of new branch')
      git.add_commit_push
    end
    lp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
    branches_page = lp.login(user.name, user.password).goto_branches_page(project.namespace, project.name)
    branches = branches_page.available_branches
    expect(branches.include?(branch)).to be true
    LOG.log('Create the merge request')
    branches_page.create_merge_request(branch, title).logout
  end

  def list_repos_for_user(user)
    cp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(user.name, user.password).goto_create_project_page
    cp.select_server(CONFIG.get(CONFIG::SECURE_GF))
    repos = cp.repo_names
    cp.logout
    repos
  end

  def list_projects_for_user(user)
    pp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(user.name, user.password).goto_projects_page
    projects = pp.projects
    pp.logout
    projects
  end

  def can_clone(user, project)
    success = false
    Dir.mktmpdir do |dir|
      git = GitHelper.http_helper(dir, project.http_url, user.name, user.password, user.email)
      git.fail_on_error=false
      success = git.clone
      create_file(dir) unless success # workaround for mktmpdir failure to unlink_internal if clone fails
    end
    success
  end

  # path should be either public or private
  def can_push(user, project, path)
    success = false
    Dir.mktmpdir(nil, tmp_client_dir) do |dir|
      git = GitHelper.http_helper(dir, project.http_url, user.name, user.password, user.email)
      git.clone # leave fail_on_error, this method should only be called for configurations with repo read permission
      git.fail_on_error=false
      create_file(File.join(dir, path))
      success = git.add_commit_push
      LOG.log("User #{user} failed to push to project #{project} at path #{path}") unless success
    end
    success
  end
end
