require_relative '../lib/base_test'

class MirroringTests < BaseTest
  i_suck_and_my_tests_are_order_dependent!

  def test_mirrored_project
    LOG.log(__method__)
    helper = GitSwarmAPIHelper.new CONFIG.get('gitswarm_url'),
                                   CONFIG.get('gitswarm_username'),
                                   CONFIG.get('gitswarm_password')
    user = 'user-'+unique_string
    password = 'Passw0rd'
    email = 'p4cloudtest+'+user+'@gmail.com'
    LOG.debug 'user = '+user

    helper.create_user(user, password, email, nil)
    project = 'project-'+unique_string
    helper.create_project(project, user)

    project_info = helper.get_project_info(project)
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
    p4_depot_path = CONFIG.get('p4_gitswarm_depot_root') + project + '/...'
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
