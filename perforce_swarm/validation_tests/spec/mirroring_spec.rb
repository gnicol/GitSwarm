require 'spec_helper'

require_relative '../lib/pages/login_page'
require_relative '../lib/pages/create_project_page'
require_relative '../lib/pages/logged_in_page'

describe 'Project Mirroring', browser: true do

  let(:admin_helper) do
    GitSwarmAPIHelper.new CONFIG.get('gitswarm_url'),
                          CONFIG.get('gitswarm_username'),
                          CONFIG.get('gitswarm_password')
  end

  let(:user) { 'user-'+unique_string }
  let(:password) { 'Passw0rd' }
  let(:uemail) { 'p4cloudtest+'+user+'@gmail.com' }
  let(:email) { 'root@mp-gs-ubuntu-12-153' }

  before do
    LOG.debug 'user = '+user
    admin_helper.create_user(user, password, uemail, nil)
  end

  describe 'New Mirrored Project' do
    let(:project) { 'project-'+unique_string }
    let(:git_dir) { Dir.mktmpdir }

    before do
      cp = LoginPage.new(@driver, CONFIG.get('gitswarm_url')).login(user, password).goto_create_project_page
      cp.project_name(project)
      cp.select_mirrored_auto
      cp.create_project_and_wait_for_clone

      user_helper = GitSwarmAPIHelper.new(CONFIG.get('gitswarm_url'), user, password)
      project_info = user_helper.get_project_info(project)
      LOG.debug project_info
      LOG.debug 'git dir = ' + git_dir

      @git = GitHelper.http_helper(git_dir, project_info[GitSwarmAPIHelper::HTTP_URL], user, password, email)
      @git.clone

      @p4_dir = Dir.mktmpdir
      LOG.debug 'p4 dir = ' + @p4_dir
      p4_depot_path = CONFIG.get('p4_gitswarm_depot_root') + user + '/' + project + '/master/...'
      @p4 = P4Helper.new(CONFIG.get('p4_port'), CONFIG.get('p4_user'), CONFIG.get('p4_password'), @p4_dir, p4_depot_path)
    end

    context 'when I push in a file to the gitswarm repo' do
      before do
        @git_filename = 'git-file-'+unique_string
        create_file(git_dir, @git_filename)
        LOG.debug 'Creating file in git : ' + @git_filename
        @git.add_commit_push
        sleep(5) # some time to let the file get into perforce
        @p4.connect_and_sync
      end

      it 'gets pushed into Perforce' do
        p4_file_from_git = @p4_dir + '/' + @git_filename
        expect(File.exist?(p4_file_from_git)).to be true
      end
    end

    context 'when I add a file to the Perforce project' do
      before do
        @p4.connect_and_sync
        @p4_filename = 'p4-file-'+unique_string
        add_path = create_file(@p4_dir, @p4_filename)
        LOG.debug 'Creating file in p4 : ' + add_path
        @p4.add(add_path)
        @p4.submit
      end

      it 'gets pulled into the gitswarm repo' do
        @git.pull
        git_file_from_p4 = git_dir + '/' + @p4_filename
        expect(File.exist?(git_file_from_p4)).to be true
      end
    end
  end
end