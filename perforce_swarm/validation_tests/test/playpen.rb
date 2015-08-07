require 'minitest/autorun'
require 'selenium-webdriver'

require_relative '../lib/base_test'
require_relative '../lib/selenium_base_test'
require_relative '../lib/git_swarm_api_helper'
require_relative '../lib/ssh_key_helper'
require_relative '../lib/git_helper'
require_relative '../lib/p4_helper'

class Playpen < BaseTest
  # def test_git
  #   user = 'bob'
  #   password = 'Passw0rd'
  #   email = 'p4cloudtest+bob@gmail.com'
  #   url_http = 'http://mp-gs-cent-7.das.perforce.com/bob/bob.git'
  #   url_ssh = 'git@mp-gs-cent-7.das.perforce.com:bob/bob.git'
  #   private_key = '/tmp/bob/private.key'
  #   public_key = '/tmp/bob/public.key'
  #
  #   dir = Dir.mktmpdir
  #   LOG.debug dir
  #
  #   git = GitHelper.http_helper(dir, url_http, user, password, email)
  #   git.clone
  #
  #   new_file = create_file(dir)
  #
  #   git.add
  #   git.commit
  #   git.push
  # end

  def test_api
    keys = SSHKeyHelper.new
    helper = GitSwarmAPIHelper.new CONFIG.get('gitswarm_url'),
                                   CONFIG.get('gitswarm_username'),
                                   CONFIG.get('gitswarm_password')

    user = 'user-'+now
    LOG.debug 'user = '+user
    helper.create_user(user, 'Passw0rd', user+'@example.com', keys.public_key_path)

    group = 'group-'+now
    helper.create_group group
    helper.add_user_to_group(user, group)

    project = 'project-'+now
    helper.create_project(project, group)
    LOG.debug helper.get_project_info(project)
    keys.delete
    helper.delete_project(project)
    helper.delete_group(group)
    helper.delete_user(user)
  end

  def test_p4
    dir = Dir.mktmpdir
    LOG.debug dir

    p4 = P4Helper.new(CONFIG.get('p4_port'),
                      CONFIG.get('p4_user'),
                      CONFIG.get('p4_password'),
                      dir,
                      '//depot/twelve/...')
    p4.connect_and_sync

    LOG.log Dir.entries(dir)

    new_file = File.open(dir+'/'+now, 'w+')
    new_file.write 'content'
    new_file.close

    p4.add(new_file.path)
    p4.submit
    p4.disconnect

    FileUtils.remove_dir(dir)
  end
end
