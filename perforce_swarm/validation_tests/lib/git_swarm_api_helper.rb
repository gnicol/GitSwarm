require 'rest-client'
require 'json'

class GitSwarmAPIHelper
  attr_accessor :raise_errors

  TOKEN_PARAM = 'private_token'
  APP         = '/api/v3/'

  #
  # Log in as the admin user and get and hold onto the Admin user's security token
  #
  def initialize(base_url, admin_username, admin_password)
    @raise_errors = false
    @base_url    = base_url + APP
    response     = RestClient.post(@base_url + 'session', login: admin_username, password: admin_password)
    @admin_token = JSON.parse(response)[TOKEN_PARAM]
  end

  #
  # Create a user.  If the path to an ssh key is provided, it will be uploaded for the user
  #
  def create_user(user, password, email, ssh_key_path = nil)
    LOG.debug('Creating GS user ' + user)
    begin
      RestClient.post(@base_url + 'users',
                      private_token: @admin_token,
                      username: user,
                      name: user,
                      password: password,
                      email: email,
                      confirm: false)
      login_response = RestClient.post(@base_url + 'session', login: user, password: password)
      user_token     = (JSON.parse login_response)[TOKEN_PARAM]

      if ssh_key_path
        key = IO.read(ssh_key_path)
        RestClient.post(@base_url + 'user/keys', private_token: user_token, title: user, key: key)
      end
    rescue => e
      LOG.log('Exception creating GS user : ' + e.inspect)
      raise e
    end
  end

  def create_group(group)
    LOG.debug('Creating GS group ' + group)
    begin
      RestClient.post(@base_url + 'groups', private_token: @admin_token, name: group, path: group)
    rescue => e
      LOG.log('Exception creating GS group : ' + e.inspect)
      raise e
    end
  end

  # Access levels are as follows
  # GUEST     = 10
  # REPORTER  = 20
  # DEVELOPER = 30
  # MASTER    = 40
  # OWNER     = 50
  # Default access level is MASTER
  def add_user_to_group(user, group, access_level = '40')
    LOG.debug("Adding GS user #{user} to group #{group}")
    RestClient.post("#{@base_url}groups/#{group_id(group)}/members",
                    private_token: @admin_token,
                    user_id: user_id(user),
                    access_level: access_level)
  end

  def create_project(project, user_or_group)
    LOG.debug 'Creating GS project ' + project + ' for namespace ' + user_or_group
    RestClient.post @base_url+'projects',
                    private_token: @admin_token,
                    name: project,
                    namespace_id: get_namespace_id(user_or_group)
  end

  def delete_user(user)
    generic_delete('user', user_id(user))
  end

  def delete_project(project)
    generic_delete('project', project_id(project))
  end

  def delete_group(group)
    generic_delete('group', group_id(group))
  end
  #
  # Returns data on a given project
  # ssh_url_to_repo and http_url_to_repo are probably useful data from the return hash
  # and will be used by tests to get the correct turl's to use after creating projects
  #
  HTTP_URL = 'http_url_to_repo'
  SSH_URL = 'SSH_url_to_repo'
  def get_project_info(project)
    LOG.debug('Getting info for project ' + project)
    search('projects', project)
  end

  private

  def generic_delete(thing, id)
    LOG.debug("Deleting GS #{thing} ID #{id}")
    thing = "#{thing}s" unless thing.end_with?('s')
    RestClient.delete(@base_url + thing + '/' + id, private_token: @admin_token)
  rescue => e
    raise e if @raise_errors
  end

  def group_id(group)
    search_id('groups', group)
  end

  def user_id(user)
    search_id('users', user)
  end

  def project_id(project)
    search_id('projects', project)
  end

  def namespace_id(namespace)
    search_id('namespaces', namespace)
  end

  def search_id(data_type, value)
    search(data_type, value)['id'].to_s
  end

  def search(data_type, value)
    results = RestClient.get(@base_url + data_type, params: { private_token: @admin_token, search: value })
    json_array = JSON.parse(results)
    fail("Unique result not found searching #{data_type} for #{value} : #{results}") if json_array.length !=1
    json_array.first
  end
end
