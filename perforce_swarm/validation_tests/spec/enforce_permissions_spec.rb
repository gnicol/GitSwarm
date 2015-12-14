require 'spec_helper'

require_relative '../lib/pages/login_page'
require_relative '../lib/pages/logged_in_page'

describe 'EnforcePermissionsTests', browser: true do
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
    @default_password = 'Passw0rd'
    @groupname = @run_id

    # These two config properties are required for these tests - fail immediately unless they are configured

    [CONFIG::SECURE_GF, CONFIG::SECURE_GF_DEPOT_ROOT].each do | property |
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

    @read_all_write_all          = @run_id + '_read_all_write_all'
    @read_all_write_partial      = @run_id + '_read_all_write_partial'
    @read_all_write_none         = @run_id + '_read_all_write_none'
    @read_partial                = @run_id + '_read_partial'
    @read_none                   = @run_id + '_read_none'
    @projects                    = [@read_all_write_all,
                                    @read_all_write_partial,
                                    @read_all_write_none,
                                    @read_partial,
                                    @read_none]
    @projects.each do | project |
      LOG.log("Project for test run : #{project}")
    end

    @user_gs_access_p4_access    = @run_id + '_gs_access_p4_access'   # in both p4 and gs and has access in both places
    @user_gs_noaccess_p4_access  = @run_id + '_gs_noaccess_p4_access' # in both p4 and gs and has access in p4 only
    @user_gs_access_p4_noaccess  = @run_id + '_gs_access_p4_noaccess' # in both p4 and gs and has access in gs only
    @user_gs_access_p4_notexist  = @run_id + '_gs_access_p4_notexist' # only in gs
    @users                       = [@user_gs_access_p4_access,
                                    @user_gs_noaccess_p4_access,
                                    @user_gs_access_p4_noaccess,
                                    @user_gs_access_p4_notexist]
    @users.each do | user |
      LOG.log("User for test run    : #{user}")
    end

    @email_domain                     = '@test.com'
    @user_email_gs_access_p4_access   = @user_gs_access_p4_access + @email_domain
    @user_email_gs_noaccess_p4_access = @user_gs_noaccess_p4_access  + @email_domain
    @user_email_gs_access_p4_noaccess = @user_gs_access_p4_noaccess + @email_domain
    @user_email_gs_access_p4_notexist = @user_gs_access_p4_notexist + @email_domain

    @p4_admin.connect
    # save the initial protects to reset to after
    @initial_protects = @p4_admin.protects

    private_dir = '/master/private'
    public_dir = '/master/public'

    if @setup
      LOG.log('Creating repo structure in p4')
      @projects.each do |dir|
        file = create_file("#{@p4_admin_dir}/#{@run_id}/#{dir}#{private_dir}", 'file.txt')
        @p4_admin.add(file)
        file = create_file("#{@p4_admin_dir}/#{@run_id}/#{dir}#{public_dir}", 'file.txt')
        @p4_admin.add(file)
      end
      @p4_admin.submit

      LOG.log('Creating Git Fusion repos')
      @projects.each do | proj |
        LOG.debug(proj)
        @git_fusion_helper.make_new_gf_repo(proj, "#{@depot_root}#{@run_id}/#{proj}")
      end
      @git_fusion_helper.apply_gf_global_config('read-permission-check' => 'user')

      LOG.log('Setting up P4 users and protections')
      @p4_admin.remove_protects('*')

      @p4_admin.create_user(@user_gs_access_p4_noaccess, @default_password, @user_email_gs_access_p4_noaccess)
      [{ name: @user_gs_access_p4_access, email: @user_email_gs_access_p4_access },
       { name: @user_gs_noaccess_p4_access, email: @user_email_gs_noaccess_p4_access }].each do | usr |
        # create user
        @p4_admin.create_user(usr[:name], @default_password, usr[:email])
        # read_all_write_all
        @p4_admin.add_write_protects(usr[:name], "#{@depot_root}#{@run_id}/#{@read_all_write_all}/...")
        # read_all_write_partial
        @p4_admin.add_read_protects(usr[:name],  "#{@depot_root}#{@run_id}/#{@read_all_write_partial}/...")
        @p4_admin.add_write_protects(usr[:name], "#{@depot_root}#{@run_id}/#{@read_all_write_partial}#{public_dir}/...")
        # read_all_write_none
        @p4_admin.add_read_protects(usr[:name],  "#{@depot_root}#{@run_id}/#{@read_all_write_none}/...")
        # read_partial
        @p4_admin.add_read_protects(usr[:name],  "#{@depot_root}#{@run_id}/#{@read_partial}#{public_dir}/...")
      end

      LOG.log('Creating GitSwarm users, and group')
      @gs_api.create_group(@groupname)
      @gs_api.create_user(@user_gs_access_p4_access, @default_password, @user_email_gs_access_p4_access)
      @gs_api.create_user(@user_gs_noaccess_p4_access, @default_password, @user_email_gs_noaccess_p4_access)
      @gs_api.create_user(@user_gs_access_p4_noaccess, @default_password, @user_email_gs_access_p4_noaccess)
      @gs_api.create_user(@user_gs_access_p4_notexist, @default_password, @user_email_gs_access_p4_notexist)
      @gs_api.add_user_to_group(@user_gs_access_p4_access, @groupname)
      # Note - @standard_user_b is not in the group
      @gs_api.add_user_to_group(@user_gs_access_p4_noaccess, @groupname)
      @gs_api.add_user_to_group(@user_gs_access_p4_notexist, @groupname)

      LOG.log('Creating GitSwarm projects')
      @driver = Browser.driver
      logged_in_page = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(CONFIG.get(CONFIG::GS_USER),
                                                                                CONFIG.get(CONFIG::GS_PASSWORD))
      @projects.each do | repo_name |
        cp = logged_in_page.goto_create_project_page
        cp.project_name(repo_name)
        cp.namespace(@groupname)
        cp.select_server(CONFIG.get(CONFIG::SECURE_GF))
        cp.select_repo(repo_name)
        cp.select_private
        cp.create_project_and_wait_for_clone
      end
      logged_in_page.logout
      Browser.reset!
    end # if @setup
  end

  # after(:all) does the teardown just once after the entire group
  after(:all) do
    LOG.log('Removing tmp dirs')
    FileUtils.rm_r(@p4_admin_dir)

    LOG.log('Skipping teardown due to setting') unless @teardown
    if @teardown
      begin
        LOG.log('Deleting created users')
        @p4_admin.delete_user(@user_gs_access_p4_access)
        @p4_admin.delete_user(@user_gs_noaccess_p4_access)
        @p4_admin.delete_user(@user_gs_access_p4_noaccess)
        @p4_admin.protects=(@initial_protects)

        @p4_admin.disconnect

        @git_fusion_helper.apply_gf_global_config('read-permission-check' => '')

        @repo_names.each do | repo_name |
          @gs_api.delete_project(repo_name)
        end
        @gs_api.delete_user(@user_gs_access_p4_access)
        @gs_api.delete_user(@user_gs_noaccess_p4_access)
        @gs_api.delete_user(@user_gs_access_p4_noaccess)
        @gs_api.delete_user(@user_gs_access_p4_notexist)
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
      available_repos = list_repos_for_user(CONFIG.get(CONFIG::GS_USER), CONFIG.get(CONFIG::GS_PASSWORD))
      LOG.log(available_repos.inspect)
      expect(available_repos).to include(@read_all_write_all)
      expect(available_repos).to include(@read_all_write_partial)
      expect(available_repos).to include(@read_all_write_none)
      expect(available_repos).to include(@read_partial)
      expect(available_repos).to include(@read_none)
    end
  end

  describe 'A user with limited read permissions in perforce' do
    it 'should be allowed to see only GF repos with full read permission when creating gs projects' do
      available_repos = list_repos_for_user(@user_gs_access_p4_access)
      LOG.log(available_repos.inspect)
      expect(available_repos).to include(@read_all_write_all)
      expect(available_repos).to include(@read_all_write_partial)
      expect(available_repos).to include(@read_all_write_none)
      expect(available_repos).to_not include(@read_partial)
      expect(available_repos).to_not include(@read_none)
    end
  end

  describe 'A user with no read permissions in perforce' do
    it 'should not be allowed to see any GF repos when creating gs projects' do
      available_repos = list_repos_for_user(@user_gs_access_p4_noaccess)
      LOG.log(available_repos.inspect)
      expect(available_repos).to_not include(@read_all_write_all)
      expect(available_repos).to_not include(@read_all_write_partial)
      expect(available_repos).to_not include(@read_all_write_none)
      expect(available_repos).to_not include(@read_partial)
      expect(available_repos).to_not include(@read_none)
    end
  end

  describe 'A user not in perforce' do
    it 'should not be allowed to see any GF repos when creating gs projects' do
      available_repos = list_repos_for_user(@user_gs_access_p4_notexist)
      LOG.log(available_repos.inspect)
      expect(available_repos).to_not include(@read_all_write_all)
      expect(available_repos).to_not include(@read_all_write_partial)
      expect(available_repos).to_not include(@read_all_write_none)
      expect(available_repos).to_not include(@read_partial)
      expect(available_repos).to_not include(@read_none)
    end
  end

  #
  # Project visibility in GitSwarm as restricted by Perforce permissions
  #

  describe 'A user with full read permissions in perforce' do
    it 'should be allowed to see all GS projects mirrored in perforce' do
      available_projects = list_projects_for_user(CONFIG.get(CONFIG::GS_USER), CONFIG.get(CONFIG::GS_PASSWORD))
      LOG.log(available_projects.inspect)
      expect(available_projects).to include(@read_all_write_all)
      expect(available_projects).to include(@read_all_write_partial)
      expect(available_projects).to include(@read_all_write_none)
      expect(available_projects).to include(@read_partial)
      expect(available_projects).to include(@read_none)
    end
  end
  describe 'A user with limited read permissions in perforce' do
    it 'should be allowed to see only GS projects mirrored in perforce where they have read permission in perforce' do
      available_projects = list_projects_for_user(@user_gs_access_p4_access)
      LOG.log(available_projects.inspect)
      expect(available_projects).to include(@read_all_write_all)
      expect(available_projects).to include(@read_all_write_partial)
      expect(available_projects).to include(@read_all_write_none)
      expect(available_projects).to_not include(@read_partial)
      expect(available_projects).to_not include(@read_none)
    end
  end

  describe 'A user with no read permissions in perforce' do
    it 'should not be allowed to see any GS projects mirrored in perforce' do
      available_projects = list_projects_for_user(@user_gs_access_p4_noaccess)
      LOG.log(available_projects.inspect)
      expect(available_projects).to_not include(@read_all_write_all)
      expect(available_projects).to_not include(@read_all_write_partial)
      expect(available_projects).to_not include(@read_all_write_none)
      expect(available_projects).to_not include(@read_partial)
      expect(available_projects).to_not include(@read_none)
    end
  end

  describe 'A user not in perforce' do
    it 'should not be allowed to see any GS projects mirrored in perforce' do
      available_projects = list_projects_for_user(@user_gs_access_p4_notexist)
      LOG.log(available_projects.inspect)
      expect(available_projects).to_not include(@read_all_write_all)
      expect(available_projects).to_not include(@read_all_write_partial)
      expect(available_projects).to_not include(@read_all_write_none)
      expect(available_projects).to_not include(@read_partial)
      expect(available_projects).to_not include(@read_none)
    end
  end

  describe 'A user with no access to the GS project' do
    it 'should not be allowed to see any GS projects even if they have read access in perforce' do
      available_projects = list_projects_for_user(@user_gs_noaccess_p4_access)
      LOG.log(available_projects.inspect)
      expect(available_projects).to_not include(@read_all_write_all)
      expect(available_projects).to_not include(@read_all_write_partial)
      expect(available_projects).to_not include(@read_all_write_none)
      expect(available_projects).to_not include(@read_partial)
      expect(available_projects).to_not include(@read_none)
    end
  end

  private

  def list_repos_for_user(user, password = @default_password)
    cp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(user, password).goto_create_project_page
    cp.select_server(CONFIG.get(CONFIG::SECURE_GF))
    repos = cp.repo_names
    cp.logout
    repos
  end

  def list_projects_for_user(user, password = @default_password)
    pp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(user, password).goto_projects_page
    projects = pp.projects
    pp.logout
    projects
  end
end
