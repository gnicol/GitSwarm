require 'minitest/autorun'
require 'selenium-webdriver'
require_relative '../lib/base_test'
require_relative '../lib/selenium_base_test'
require_relative '../lib/git_swarm_api_helper'
require_relative '../lib/ssh_key_helper'

class Playpen < BaseTest
  #
  # def test_zero
  #   LOG.debug ('zero')
  #
  #   LOG.debug (@@config['username'])
  #   LOG.debug (@@config['password'])
  # end

  def test_api
    keys = SSHKeyHelper.new
    helper = GitSwarmAPIHelper.new @@config['gitswarm_url'],
                                   @@config['gitswarm_username'],
                                   @@config['gitswarm_password']

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
  end

  # def test_five
  #   p4 = P4.new
  #   p4.port = @@config['p4_port']
  #   LOG.debug p4.port
  #   p4.connect
  #   p4.run('users').each { |user|
  #     LOG.log  user['User']
  #   }
  #
  #   p4.disconnect
  #
  # end

  # def test_one
  #   LOG.debug('one')
  #   @driver.navigate.to 'http://google.com'
  #   element = @driver.find_element(:name, 'q')
  #   element.send_keys('Moo')
  #   element.submit
  #   LOG.debug(@driver.title)
  #
  #   assert_equal(@driver.title, "Moo - Google Search", "Title not as expected")
  # end

  #
  # def test_two
  #   LOG.debug('two')
  #   assert_equal("moo", "poo", "poo not moo")
  # end
end
