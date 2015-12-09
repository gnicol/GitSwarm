require 'spec_helper'

require_relative '../lib/pages/login_page'
require_relative '../lib/pages/logged_in_page'

describe 'EnforcePermissionsTests', browser: false do
  # before(:all) does the setup just once before the entire group
  # https://www.relishapp.com/rspec/rspec-core/v/2-2/docs/hooks/before-and-after-hooks
  before(:all) do
    # local variables to control whether setup /teardown is performed.
    # Allows us to do a single setup and reuse it for test development to save time
    # You must change @run_id to a static variable if you skip setup
    @setup = true
    @teardown = true
    @run_id = unique_string

    LOG.log('Skipping setup due to setting') unless @setup
    LOG.log("run_id for this run is #{@run_id}")
    @default_password = 'Passw0rd'
    @groupname = @run_id

    # These two config properties are required for these tests - fail immediately unless they are configured
    @secure_git_fusion = 'secure_git_fusion'
    @secure_git_fusion_depot_root = 'secure_git_fusion_depot_root'

    [@secure_git_fusion, @secure_git_fusion_depot_root].each do | property |
      fail("Required config.yml property does not exist: #{property}") unless CONFIG.get(property)
    end

    @p4_admin_dir = Dir.mktmpdir

    LOG.log 'p4 admin dir = ' + @p4_admin_dir

    @depot_root = CONFIG.get('secure_git_fusion_depot_root')
    @p4_admin = P4Helper.new(CONFIG.get('p4_port'),
                             CONFIG.get('p4_user'),
                             CONFIG.get('p4_password'),
                             @p4_admin_dir,
                             @depot_root+'...')

    @git_fusion_helper = GitFusionHelper.new(CONFIG.get('p4_port'),
                                             CONFIG.get('p4_user'),
                                             CONFIG.get('p4_password'))

    @gs_api = GitSwarmAPIHelper.new(CONFIG.get('gitswarm_url'),
                                    CONFIG.get('gitswarm_username'),
                                    CONFIG.get('gitswarm_password'))

    @read_all_write_all       = 'read_all_write_all'
    @read_all_write_partial   = 'read_all_write_partial'
    @read_all_write_none      = 'read_all_write_none'
    @read_partial             = 'read_partial'
    @read_none                = 'read_none'
    @projects = [@read_all_write_all,
                 @read_all_write_partial,
                 @read_all_write_none,
                 @read_partial,
                 @read_none]

    @standard_user_a          = @run_id + '_standard_user_a' # is in both p4 and gs and has access in both places
    @standard_user_b          = @run_id + '_standard_user_b' # is in both p4 and gs and has access in p4 only
    @low_user                 = @run_id + '_low_user'        # is in both p4 and gs and has access in gs only
    @gs_only_user             = @run_id + '_gs_only_user'    # is only in gs

    @email_domain             = '@test.com'
    @standard_user_a_email    = @standard_user_a + @email_domain
    @standard_user_b_email    = @standard_user_b  + @email_domain
    @low_user_email           = @low_user + @email_domain
    @gs_only_user_email       = @gs_only_user + @email_domain

    @p4_admin.connect
    # save the initial protects to reset to after
    @initial_protects = @p4_admin.protects

    LOG.log('Creating repo structure in p4')
    private_dir = '/master/private'
    public_dir = '/master/public'

    if @setup
      @projects.each do |dir|
        file = create_file("#{@p4_admin_dir}/#{@run_id}/#{dir}#{private_dir}", 'file.txt')
        @p4_admin.add(file)
        file = create_file("#{@p4_admin_dir}/#{@run_id}/#{dir}#{public_dir}", 'file.txt')
        @p4_admin.add(file)
      end
      @p4_admin.submit
    end

    LOG.log('Creating Git Fusion repos') if @setup
    @repo_names = [] # run-id specific repo names
    @projects.each do | proj |
      repo = "#{@run_id}_#{proj}"
      @repo_names << repo
      LOG.debug(repo)
      @git_fusion_helper.make_new_gf_repo(repo, "#{@depot_root}#{@run_id}/#{proj}") if @setup
    end

    LOG.log('Setting up P4 users and protections')
    if @setup
      @p4_admin.remove_protects('*')

      @p4_admin.create_user(@low_user, @default_password, @low_user_email)
      [{ name: @standard_user_a, email: @standard_user_a_email },
       { name: @standard_user_b, email: @standard_user_b_email }].each do | usr |
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
      @gs_api.create_user(@standard_user_a, @default_password, @standard_user_a_email)
      @gs_api.create_user(@standard_user_b, @default_password, @standard_user_b_email)
      @gs_api.create_user(@low_user, @default_password, @low_user_email)
      @gs_api.create_user(@gs_only_user, @default_password, @gs_only_user_email)
      @gs_api.add_user_to_group(@standard_user_a, @groupname)
      # Note - @standard_user_b is not in the group
      @gs_api.add_user_to_group(@low_user, @groupname)
      @gs_api.add_user_to_group(@gs_only_user, @groupname)

      LOG.log('Creating GitSwarm projects')
      @driver = Browser.driver
      logged_in_page = LoginPage.new(@driver, CONFIG.get('gitswarm_url')).login(CONFIG.get('gitswarm_username'),
                                                                                CONFIG.get('gitswarm_password'))
      @repo_names.each do | repo_name |
        cp = logged_in_page.goto_create_project_page
        cp.project_name(repo_name)
        cp.namespace(@groupname)
        cp.select_server(CONFIG.get('secure_git_fusion'))
        cp.select_repo(repo_name)
        cp.select_private
        cp.create_project_and_wait_for_clone
      end
      logged_in_page.logout
      Browser.reset!
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
        @p4_admin.delete_user(@standard_user_a)
        @p4_admin.delete_user(@standard_user_b)
        @p4_admin.delete_user(@low_user)
        @p4_admin.protects=(@initial_protects)

        @p4_admin.disconnect

        @repo_names.each do | repo_name |
          @gs_api.delete_project(repo_name)
        end
        @gs_api.delete_user(@standard_user_a)
        @gs_api.delete_user(@standard_user_b)
        @gs_api.delete_user(@low_user)
        @gs_api.delete_user(@gs_only_user)
        @gs_api.delete_group(@groupname)
      rescue => e
        LOG.log('Exception raised in after block : '+e.message)
        LOG.log(e.backtrace.join('\n'))
      end
    end
  end

  describe 'test' do
    it 'should have do x' do
      LOG.log('test1')
    end
  end

  describe 'test2' do
    it 'should have do y' do
      LOG.log('test2')
    end
  end
end
