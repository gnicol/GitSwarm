require 'minitest/autorun'
require 'selenium-webdriver'

require_relative '../lib/base_test'
require_relative '../lib/selenium_base_test'
require_relative '../lib/git_swarm_api_helper'
require_relative '../lib/ssh_key_helper'
require_relative '../lib/git_helper'
require_relative '../lib/p4_helper'
require_relative '../lib/page'
require_relative '../lib/pages/login_page'
#
# This entire class is for trying things out, not 'production' code.
# Should not be checked in.
#
#

class Playpen < SeleniumBaseTest


  def test_pages
    login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
    login.enter_credentials(CONFIG.get('gitswarm_username'), CONFIG.get('gitswarm_password'))
    dashboard = login.click_login_expecting_dashboard
    dashboard.logout

  end

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

  # def test_api
  #   LOG.log(__method__)
  #   keys = SSHKeyHelper.new
  #   helper = GitSwarmAPIHelper.new CONFIG.get('gitswarm_url'),
  #                                  CONFIG.get('gitswarm_username'),
  #                                  CONFIG.get('gitswarm_password')
  #
  #   user = 'user-'+unique_string
  #   LOG.debug 'user = '+user
  #   helper.create_user(user, 'Passw0rd', user+'@example.com', keys.public_key_path)
  #
  #   group = 'group-'+unique_string
  #   helper.create_group group
  #   helper.add_user_to_group(user, group)
  #
  #   project = 'project-'+unique_string
  #   helper.create_project(project, group)
  #   LOG.debug helper.get_project_info(project)
  #   keys.delete
  #   helper.delete_project(project)
  #   helper.delete_group(group)
  #   helper.delete_user(user)
  # end
  #
  # def test_p4
  #   LOG.log(__method__)
  #   dir = Dir.mktmpdir
  #   LOG.debug dir
  #
  #   p4 = P4Helper.new(CONFIG.get('p4_port'),
  #                     CONFIG.get('p4_user'),
  #                     CONFIG.get('p4_password'),
  #                     dir,
  #                     '//depot/twelve/...')
  #   p4.connect_and_sync
  #
  #   LOG.log Dir.entries(dir)
  #
  #   new_file = File.open(dir+'/'+unique_string, 'w+')
  #   new_file.write 'content'
  #   new_file.close
  #
  #   p4.add(new_file.path)
  #   p4.submit
  #   p4.disconnect
  #
  #   FileUtils.remove_dir(dir)
  # end
end
