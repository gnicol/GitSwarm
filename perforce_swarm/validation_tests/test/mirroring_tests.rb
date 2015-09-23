require_relative '../lib/selenium_base_test'
require_relative '../lib/page'
require_relative '../lib/pages/login_page'
require_relative '../lib/pages/create_project_page'
require_relative '../lib/pages/logged_in_page'

class MirroringTests < SeleniumBaseTest
  i_suck_and_my_tests_are_order_dependent!

  def test_mirrored_project
    LOG.log(__method__)
    admin_helper = GitSwarmAPIHelper.new CONFIG.get('gitswarm_url'),
                                         CONFIG.get('gitswarm_username'),
                                         CONFIG.get('gitswarm_password')
    user = 'user-'+unique_string
    password = 'Passw0rd'
    uemail = 'p4cloudtest+'+user+'@gmail.com'
    email = 'root@mp-gs-ubuntu-12-153'
    LOG.debug 'user = '+user

    admin_helper.create_user(user, password, uemail, nil)
    project = 'project-'+unique_string
    # admin_helper.create_project(project, user)

    cp = LoginPage.new(@driver, CONFIG.get('gitswarm_url')).login(user, password).goto_create_project_page
    cp.project_name(project)
    cp.select_mirrored_auto
    cp.create_project_and_wait_for_clone

    user_helper = GitSwarmAPIHelper.new(CONFIG.get('gitswarm_url'), user, password)
    project_info = user_helper.get_project_info(project)
    LOG.debug project_info

    git_dir = Dir.mktmpdir

    LOG.debug 'git dir = ' + git_dir

    git = GitHelper.http_helper(git_dir, project_info[GitSwarmAPIHelper::HTTP_URL], user, password, email)
    git.clone
    git_filename = 'git-file-'+unique_string
    create_file(git_dir, git_filename)
    LOG.debug 'Creating file in git : ' + git_filename
    git.add_commit_push

    p4_dir = Dir.mktmpdir
    LOG.debug 'p4 dir = ' + p4_dir
    p4_depot_path = CONFIG.get('p4_gitswarm_depot_root') + user + '/' + project + '/...'
    p4 = P4Helper.new(CONFIG.get('p4_port'), CONFIG.get('p4_user'), CONFIG.get('p4_password'), p4_dir, p4_depot_path)
    p4.connect_and_sync

    p4_file_from_git = p4_dir + '/' + git_filename
    assert(File.exist?(p4_file_from_git), 'Expected file not found in perforce : ' + git_filename)

    p4_filename = 'p4-file-'+unique_string
    create_file(p4_dir, p4_filename)
    LOG.debug 'Creating file in p4 : ' + p4_filename
    p4.add(p4_filename)
    p4.submit

    git.pull
    git_file_from_p4 = git_dir + '/' + p4_filename
    assert(File.exist?(git_file_from_p4), 'Expected file not found in git : ' + p4_filename)
  end
end
