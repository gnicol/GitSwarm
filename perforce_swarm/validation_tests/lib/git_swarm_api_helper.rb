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
  # Create a user.  If the path to an ssh key is provided, it will be uploaded for the user
  #
  def create_user(user, password, email, ssh_key_path = nil)
    LOG.debug 'Creating user '+ user
    RestClient.post @base_url+'users',
                    private_token: @admin_token,
                    username: user,
                    name: user,
                    password: password,
                    email: email,
                    confirm: false
    login_response = RestClient.post @base_url + 'session', login: user, password: password
    user_token = (JSON.parse login_response)[TOKEN_PARAM]

    if ssh_key_path
      key = IO.read(ssh_key_path)
      RestClient.post @base_url+'user/keys',
                      private_token: user_token,
                      title: user,
                      key: key
    end
  end

  def create_group(group)
    LOG.debug 'Creating group '+ group
    RestClient.post @base_url+'groups',
                    private_token: @admin_token,
                    name: group,
                    path: group
  end

  def add_user_to_group(user, group)
    LOG.debug 'Adding user ' + user + ' to group ' + group
    RestClient.post @base_url+'groups/'+get_group_id(group)+'/members',
                    private_token: @admin_token,
                    user_id: get_user_id(user),
                    access_level: '40'
  end

  def create_project(project, user_or_group)
    LOG.debug 'Creating project ' + project + ' for namespace ' + user_or_group
    RestClient.post @base_url+'projects',
                    private_token: @admin_token,
                    name: project,
                    namespace_id: get_namespace_id(user_or_group)
  end

  def delete_user(user)
    LOG.debug 'Deleting user ' + user
    RestClient.delete @base_url+'users/'+ get_user_id(user), private_token: @admin_token
  end

  def delete_project(project)
    LOG.debug 'Deleting project ' + project
    RestClient.delete @base_url+'projects/'+ get_project_id(project), private_token: @admin_token
  end

  def delete_group(group)
    LOG.debug 'Deleting group ' + group
    RestClient.delete @base_url+'groups/'+ get_group_id(group), private_token: @admin_token
  end

  def update_admin_password(user, new_password)
    LOG.debug 'Updating admin user '+ user + ' password to ' + new_password
    # admin_user = RestClient.get @base_url+'users/'+ get_user_id(user), private_token: @admin_token
    RestClient.put @base_url + 'users/' + get_user_id(user), private_token: @admin_token, password: new_password
  end

  #
  # Returns data on a given project
  # ssh_url_to_repo and http_url_to_repo are probably useful data from the return hash
  # and will be used by tests to get the correct url's to use after creating projects
  #
  HTTP_URL = 'http_url_to_repo'
  SSH_URL = 'SSH_url_to_repo'
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

  def get_project_id(project)
    projects = RestClient.get @base_url+'projects', params: { private_token: @admin_token, search: project }
    (JSON.parse projects).first['id'].to_s
  end

  def get_namespace_id(namespace)
    namespaces = RestClient.get @base_url+'namespaces', params: { private_token: @admin_token, search: namespace }
    (JSON.parse namespaces).first['id'].to_s
  end
end
