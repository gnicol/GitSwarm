require 'spec_helper'

require_relative '../lib/pages/login_page'
require_relative '../lib/pages/create_project_page'
require_relative '../lib/pages/logged_in_page'
require_relative '../lib/pages/project_page'
require_relative '../lib/pages/edit_file_page'

describe 'New Mirrored Project', browser: true do
  let(:user) { 'user-'+unique_string }
  let(:password) { 'Passw0rd' }
  let(:uemail) { 'p4cloudtest+'+user+'@gmail.com' }
  let(:email) { 'root@mp-gs-ubuntu-12-153' }
  let(:project) { 'project-'+unique_string }
  let(:expected_gf_repo_name) { 'gitswarm-'+user+'-'+project }
  let(:git_dir) { Dir.mktmpdir }
  let(:p4_dir) {  Dir.mktmpdir }
  let(:another_project) { 'another_project-'+unique_string }
  let(:another_git_dir) { Dir.mktmpdir }

  before do
    create_user
    create_new_project
    clone_project(project, git_dir)

    LOG.debug 'p4 dir = ' + p4_dir
    LOG.debug 'user is ' + user + ' : ' + password
    p4_depot_path = CONFIG.get('p4_gitswarm_depot_root') + user + '/' + project + '/master/...'
    @p4 = P4Helper.new(CONFIG.get('p4_port'), CONFIG.get('p4_user'), CONFIG.get('p4_password'), p4_dir, p4_depot_path)
  end

  context 'when I push in a file to the gitswarm repo' do
    before do
      @git_filename = 'git-file-'+unique_string
      create_file(git_dir, @git_filename)
      LOG.debug 'Creating file in git : ' + @git_filename
      @git.add_commit_push
      sleep(2) # some time to let the file get into perforce
    end

    it 'gets pushed into Perforce' do
      @p4.connect_and_sync
      p4_file_from_git = p4_dir + '/' + @git_filename
      expect(File.exist?(p4_file_from_git)).to be true
    end
  end

  context 'when I add a file to the Perforce project' do
    before do
      @p4.connect_and_sync
      @p4_filename = 'p4-file-'+unique_string
      add_path = create_file(p4_dir, @p4_filename)
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

  context 'when a repo was created in GitFusion' do
    it 'is visible in the list of available repos' do
      cp = LoginPage.new(@driver, CONFIG.get('gitswarm_url')).login(user, password).goto_create_project_page
      available_repos = cp.repo_names
      expect(available_repos.include?(expected_gf_repo_name)).to be true
    end
  end

  context 'when an existing repo with content is mirrored in a new project' do
    before do
      @git_filename = 'git-file-'+unique_string
      create_file(git_dir, @git_filename)
      LOG.debug 'Creating file in git : ' + @git_filename
      @git.add_commit_push

      @p4.connect_and_sync
      @p4_filename = 'p4-file-'+unique_string
      add_path = create_file(p4_dir, @p4_filename)
      LOG.debug 'Creating file in p4 : ' + add_path
      @p4.add(add_path)
      @p4.submit

      cp = LoginPage.new(@driver, CONFIG.get('gitswarm_url')).login(user, password).goto_create_project_page
      cp.project_name(another_project)
      cp.select_mirrored_specific
      cp.select_repo(expected_gf_repo_name)
      cp.create_project_and_wait_for_clone
    end

    it 'contains files from that repo' do
      clone_project(another_project, another_git_dir)
      existing_git_file_from_p4 = another_git_dir + '/' + @p4_filename
      existing_p4_file_from_git = another_git_dir + '/' + @git_filename
      expect(File.exist?(existing_git_file_from_p4)).to be true
      expect(File.exist?(existing_p4_file_from_git)).to be true
    end
  end

  context 'when a file is added to a project through the web ui' do
    filename = 'Readme.md'
    unique_content = unique_string
    before do
      proj_page = LoginPage.new(@driver,
                                CONFIG.get('gitswarm_url')).login(user, password).goto_project_page(user, project)
      edit_page = proj_page.add_readme
      filename = edit_page.file_name
      edit_page.content=unique_content
      edit_page.commit_message='auto-message'
      p = edit_page.commit_change
      p.logout
    end

    it 'is mirrored into perforce' do
      @p4.connect_and_sync
      expected_file = p4_dir + '/' + filename
      expect(File.exist?(expected_file)).to be true

      f = File.open(expected_file, 'rb')
      contents = f.read
      f.close
      LOG.log('contents = ' +contents)
      LOG.log('expected contents = ' + unique_content)
      expect(contents).to eq(unique_content)
    end
  end

  def create_user
    GitSwarmAPIHelper.new(CONFIG.get('gitswarm_url'),
                          CONFIG.get('gitswarm_username'),
                          CONFIG.get('gitswarm_password')
    ).create_user(user, password, uemail, nil)
  end

  def create_new_project
    cp = LoginPage.new(@driver, CONFIG.get('gitswarm_url')).login(user, password).goto_create_project_page
    cp.project_name(project)
    cp.select_mirrored_auto
    cp.create_project_and_wait_for_clone
    cp.logout
  end

  def clone_project(project_name, dir)
    user_helper = GitSwarmAPIHelper.new(CONFIG.get('gitswarm_url'), user, password)
    project_info = user_helper.get_project_info(project_name)
    LOG.debug project_info
    LOG.debug 'git dir = ' + dir

    @git = GitHelper.http_helper(dir, project_info[GitSwarmAPIHelper::HTTP_URL], user, password, email)
    @git.clone
  end
end
