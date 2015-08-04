require 'rest-client'
require 'json'

class GitSwarmAPIHelper
  TOKEN_PARAM = 'private_token'
  APP = '/api/v3/'

  #
  # Log in as the admin user and get and hold onto the Admin user's security token
  #
  def initialize(base_url, admin_username, admin_password)
    @base_url = base_url + APP
    response = RestClient.post @base_url + 'session', login: admin_username, password: admin_password
    @admin_token = (JSON.parse response)[TOKEN_PARAM]
  end

  #
  # Create a user and upload an ssh key for them
  #
  def create_user(user, password, email, ssh_key_path)
    LOG.debug 'Creating user '+ user
    RestClient.post @base_url+'users', private_token: @admin_token,
                                       username: user,
                                       name: user,
                                       password: password,
                                       email: email
    login_response = RestClient.post @base_url + 'session', login: user, password: password
    user_token = (JSON.parse login_response)[TOKEN_PARAM]

    key = IO.read(ssh_key_path)
    RestClient.post @base_url+'user/keys', private_token: user_token,
                                           title: user,
                                           key: key
  end

  def create_group(group)
    LOG.debug 'Creating group '+ group
    RestClient.post @base_url+'groups', private_token: @admin_token,
                                        name: group,
                                        path: group
  end

  def add_user_to_group(user, group)
    LOG.debug 'Adding user ' + user + ' to group ' + group
    RestClient.post @base_url+'groups/'+get_group_id(group)+'/members', private_token: @admin_token,
                                                                        user_id: get_user_id(user),
                                                                        access_level: '40'
  end

  def create_project(project, userOrGroup)
    LOG.debug 'Creating project ' + project + ' for namespace ' + userOrGroup
    RestClient.post @base_url+'projects', private_token: @admin_token,
                                          name: project,
                                          namespace_id: get_namespace_id(userOrGroup)
  end

  #
  # Returns data on a given project
  # ssh_url_to_repo and http_url_to_repo are probably useful data from the return hash
  #
  def get_project_info(project)
    LOG.debug 'Getting info for project ' + project
    projects = RestClient.get @base_url+'projects', params: { private_token: @admin_token, search: project }
    (JSON.parse projects).first
  end

  def get_group_id(group)
    groups = RestClient.get @base_url+'groups', params: { private_token: @admin_token, search: group }
    (JSON.parse groups).first['id'].to_s
  end

  def get_user_id(user)
    users = RestClient.get @base_url+'users', params: { private_token: @admin_token, search: user }
    (JSON.parse users).first['id'].to_s
  end

  def get_namespace_id(namespace)
    namespaces = RestClient.get @base_url+'namespaces', params: { private_token: @admin_token, search: namespace }
    (JSON.parse namespaces).first['id'].to_s
  end
end
