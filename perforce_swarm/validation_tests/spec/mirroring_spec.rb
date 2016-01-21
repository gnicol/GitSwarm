require 'spec_helper'

require_relative '../lib/page'
require_relative '../lib/user'
require_relative '../lib/project'

describe 'New Mirrored Project', browser: true do
  let(:run_id)                { unique_string }
  let(:user)                  { User.new('user-' + run_id) }
  let(:project)               { Project.new('project-'+run_id) }
  let(:expected_gf_repo_name) { "gitswarm-#{user.name}-#{project.name}" }
  let(:git_dir)               { Dir.mktmpdir('Git-', tmp_client_dir) }
  let(:p4_dir)                { Dir.mktmpdir('P4-', tmp_client_dir) }

  before do
    LOG.debug("p4 dir = #{p4_dir}")
    LOG.debug("user is #{user.name} : #{user.password}")
    p4_depot_path = "#{CONFIG.get('p4_gitswarm_depot_root')}#{user.name}/#{project.name}/master/..."
    @p4 = P4Helper.new(CONFIG.get(CONFIG::P4_PORT),
                       CONFIG.get(CONFIG::P4_USER),
                       CONFIG.get(CONFIG::P4_PASSWORD), p4_dir, p4_depot_path)
    create_user
  end

  after do
    delete_user # deleting user will also delete user's projects
  end

  context 'when I push in a file to the gitswarm repo' do
    commit_message = 'commit_message_'+unique_string
    before do
      create_new_project
      clone_project(project, git_dir)
      @git_filename = 'git-file-'+unique_string
      create_file(git_dir, @git_filename)
      LOG.debug 'Creating file in git : ' + @git_filename
      @git.add_commit_push(commit_message)
      sleep(2) # some time to let the file get into perforce
    end

    it 'gets pushed into Perforce with the commit message and email' do
      @p4.connect_and_sync
      p4_file_from_git = p4_dir + '/' + @git_filename
      # Verify file exists in P4
      p4_file_exists = run_block_with_retry(12, 5) do
        @p4.sync
        File.exist?(p4_file_from_git)
      end
      LOG.log('File added to git exists in Perforce after we mirror? = ' + p4_file_exists.to_s)
      expect(p4_file_exists).to be true

      output = @p4.last_commit_message(p4_file_from_git)
      LOG.debug('Changelist in perforce is : '+output.to_s)
      changelist_description = output.fetch('desc')
      expect(changelist_description.include?(commit_message)).to be true
      expect(changelist_description.include?(user.email)).to be true
    end
  end

  context 'when I add a file to the Perforce project' do
    before do
      create_new_project
      clone_project(project, git_dir)
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
    before do
      create_new_project
    end
    it 'is visible in the list of available repos' do
      cp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(user.name, user.password).goto_create_project_page
      available_repos = cp.repo_names
      expect(available_repos.include?(expected_gf_repo_name)).to be true
    end
  end

  context 'when an existing repo with content is mirrored in a new project' do
    another_project = Project.new('another_project-' + unique_string)
    another_git_dir = Dir.mktmpdir('AnotherGit-', tmp_client_dir)
    before do
      create_new_project
      clone_project(project, git_dir)
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

      cp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(user.name, user.password).goto_create_project_page
      cp.project_name(another_project.name)
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
      create_new_project
      lp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      proj_page = lp.login(user.name, user.password).goto_project_page(user.name, project.name)
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

  context 'when I merge a branch into master' do
    new_branch = unique_string
    new_file = new_branch+'-file'
    before do
      create_new_project
      clone_project(project, git_dir)
      LOG.log('Add a file to master branch so it exists')
      create_file(git_dir, 'master-file')
      @git.add_commit_push

      LOG.log 'Branching new branch '+new_branch
      @git.branch_and_checkout(new_branch)
      create_file(git_dir, new_file)
      LOG.log('Adding file to new branch '+new_file)
      @git.add_commit_push
    end

    it 'gets pushed into Perforce' do
      @p4.connect_and_sync
      p4_file_from_git = p4_dir + '/' + new_file
      LOG.log('Check the file does not exist in perforce before the branch is merged')
      expect(File.exist?(p4_file_from_git)).to be false

      lp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      branches_page = lp.login(user.name, user.password).goto_branches_page(user.name, project.name)
      branches = branches_page.available_branches
      expect(branches.include?(new_branch)).to be true
      LOG.log('Merge the branch')
      branches_page.create_and_accept_merge_request(new_branch)

      @p4.sync
      LOG.log('Check the file exists in perforce after the branch is merged')
      expect(File.exist?(p4_file_from_git)).to be true
    end
  end

  context 'when I mirror a existing non-mirrored project with content' do
    before do
      git_filename = 'git-file-'+unique_string
      @p4_file_from_git = p4_dir + '/' + git_filename

      create_new_project(false)
      clone_project(project, git_dir)
      create_file(git_dir, git_filename)
      LOG.debug 'Creating file in git : ' + git_filename
      @git.add_commit_push
      sleep(2) # some time to let the file get into perforce

      @p4.connect_and_sync
      LOG.log('File added to git exists in Perforce before we mirror? = ' + File.exist?(@p4_file_from_git).to_s)
      expect(File.exist?(@p4_file_from_git)).to be false

      lp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      pp = lp.login(user.name, user.password).goto_project_page(user.name, project.name)
      LOG.log('Project is mirrored? ' + pp.mirrored_in_helix?.to_s)
      expect(pp.mirrored_in_helix?).to be false
      config_mirroring = pp.click_mirror_in_helix
      pp = config_mirroring.mirror_project_and_wait
      LOG.debug('Project is mirrored? ' + pp.mirrored_in_helix?.to_s)
      expect(pp.mirrored_in_helix?).to be true
    end

    it 'should be mirrored into perforce' do
      p4_file_exists = run_block_with_retry(12, 5) do
        @p4.sync
        File.exist?(@p4_file_from_git)
      end
      LOG.log('File added to git exists in Perforce after we mirror? = ' + p4_file_exists.to_s)
      expect(p4_file_exists).to be true
    end
  end

  def create_user
    GitSwarmAPIHelper.new(CONFIG.get(CONFIG::GS_URL),
                          CONFIG.get(CONFIG::GS_USER),
                          CONFIG.get(CONFIG::GS_PASSWORD)
                         ).create_user(user.name, user.password, user.email, nil)
  end

  def delete_user
    GitSwarmAPIHelper.new(CONFIG.get(CONFIG::GS_URL),
                          CONFIG.get(CONFIG::GS_USER),
                          CONFIG.get(CONFIG::GS_PASSWORD)
                         ).delete_user(user.name)
  end

  def create_new_project(mirrored = true, public_project = false)
    cp = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL)).login(user.name, user.password).goto_create_project_page
    cp.project_name(project.name)
    cp.select_mirrored_auto if mirrored
    cp.select_public if public_project
    cp.create_project_and_wait_for_clone
    cp.logout
  end

  def delete_project(project)
    GitSwarmAPIHelper.new(CONFIG.get(CONFIG::GS_URL),
                          CONFIG.get(CONFIG::GS_USER),
                          CONFIG.get(CONFIG::GS_PASSWORD)
                         ).delete_project(project.name)
  end

  def clone_project(project, dir)
    user_helper = GitSwarmAPIHelper.new(CONFIG.get(CONFIG::GS_URL), user.name, user.password)
    project_info = user_helper.get_project_info(project.name)
    LOG.debug project_info
    LOG.debug 'git dir = ' + dir

    @git = GitHelper.http_helper(dir, project_info[GitSwarmAPIHelper::HTTP_URL], user.name, user.password, user.email)
    @git.clone
  end
end
