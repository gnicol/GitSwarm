require 'spec_helper'

require_relative '../lib/pages/login_page'
require_relative '../lib/pages/logged_in_page'

describe 'EnforcePermissionsTests', browser: false do
  # before(:all) does the setup just once before the entire group
  # https://www.relishapp.com/rspec/rspec-core/v/2-2/docs/hooks/before-and-after-hooks
  before(:all) do
    @p4_admin_dir = Dir.mktmpdir
    @run_id = unique_string
    @default_password = 'Passw0rd'

    LOG.log 'p4 admin dir = ' + @p4_admin_dir

    @depot_root = '//depot'
    @p4_admin = P4Helper.new(CONFIG.get('p4_port'),
                             CONFIG.get('p4_user'),
                             CONFIG.get('p4_password'),
                             @p4_admin_dir,
                             @depot_root+'/...')

    @gs_api = GitSwarmAPIHelper.new(CONFIG.get('gitswarm_url'),
                                    CONFIG.get('gitswarm_username'),
                                    CONFIG.get('gitswarm_password'))

    @read_all_write_all       = 'read_all_write_all'
    @read_all_write_partial   = 'read_all_write_partial'
    @read_all_write_none      = 'read_all_write_none'
    @read_partial             = 'read_partial'
    @read_none                = 'read_none'

    @standard_user_a          = @run_id + '_standard_user_a'
    @standard_user_b          = @run_id + '_standard_user_b'
    @low_user                 = @run_id + '_low_user'
    @gs_only_user             = @run_id + '_gs_only_user'

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
    [@read_all_write_all,
     @read_all_write_partial,
     @read_all_write_none,
     @read_partial,
     @read_none].each do |dir|
      file = create_file(@p4_admin_dir+"/#{@run_id}/"+dir+private_dir, 'file.txt')
      @p4_admin.add(file)
      file = create_file(@p4_admin_dir+"/#{@run_id}/"+dir+public_dir, 'file.txt')
      @p4_admin.add(file)
    end
    @p4_admin.submit

    LOG.log('Setting up users and protections')
    @p4_admin.remove_protects('*')
    @p4_admin.create_user(@low_user, @default_password, @low_user_email)
    [ {:name=>@standard_user_a, :email=>@standard_user_a_email},
      {:name=>@standard_user_b, :email=>@standard_user_b_email} ].each do | usr |
      # create user
      @p4_admin.create_user(usr[:name], @default_password, usr[:email])
      # read_all_write_all
      @p4_admin.add_write_protects(usr[:name], @depot_root+"/#{@run_id}/"+@read_all_write_all+'/...')
      # read_all_write_partial
      @p4_admin.add_read_protects(usr[:name], @depot_root+"/#{@run_id}/"+@read_all_write_partial+'/...')
      @p4_admin.add_write_protects(usr[:name], @depot_root+"/#{@run_id}/"+@read_all_write_partial+public_dir+'/...')
      # read_all_write_none
      @p4_admin.add_read_protects(usr[:name], @depot_root+"/#{@run_id}/"+@read_all_write_none+'/...')
      #read_partial
      @p4_admin.add_read_protects(usr[:name], @depot_root+"/#{@run_id}/"+@read_partial+public_dir+'/...')
    end
  end

  # after(:all) does the teardown just once after the entire group
  after(:all) do
    LOG.log('Removing tmp dirs')
    FileUtils.rm_r(@p4_admin_dir)
    LOG.log('Deleting created users')
    @p4_admin.delete_user(@standard_user_a)
    @p4_admin.delete_user(@standard_user_b)
    @p4_admin.delete_user(@low_user)
    @p4_admin.protects=(@initial_protects)

    @p4_admin.disconnect
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
