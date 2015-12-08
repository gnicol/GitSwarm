# Adding in the require_relative 'logged_in_page' line to ensure that the autoloader does not fail
# with the error "uninitialized constant LoggedInPage (NameError)"
require_relative 'logged_in_page'
require_relative '../page'
require_relative 'select2_module'

class CreateProjectPage < LoggedInPage
  include Select2Module

  def initialize(driver)
    super(driver)
    @repo_selector = 's2id_git_fusion_repo_name'
    @server_selector = 's2id_git_fusion_entry'
    @namespace_selector = 's2id_project_namespace_id'
    wait_for_gf_options_to_load
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:id, 'project_path'] # project name
    elems << [:name, 'commit'] # create project button
    if servers_exist?
      elems << [:id, 'git_fusion_auto_create_nil'] # Not mirrored
      elems << [:id, 'git_fusion_auto_create_true'] # auto-create mirrored
      elems << [:id, 'git_fusion_auto_create_false'] # mirror existing
      elems << [:id, 'git_fusion_entry'] # GF server selection dropdown
      # elems << [:id, 'git_fusion_repo_name'] # GF repo selector - there may not be one if no repos exist
    end
    elems
  end

  def project_name(name)
    field = @driver.find_element(:id, 'project_path')
    field.clear
    field.send_keys(name)
  end

  def namespace(namespace)
    select2_select(@namespace_selector, namespace)
  end

  def namespaces
    select2_options(@namespace_selector)
  end

  def selected_namespace
    select2_selected(@namespace_selector)
  end

  def create_project_and_wait_for_clone
    @driver.find_element(:name, 'commit').click
    ProjectPage.new(@driver)
  end

  def select_mirrored_none
    @driver.find_element(:id, 'git_fusion_auto_create_nil').click
  end

  def select_mirrored_auto
    @driver.find_element(:id, 'git_fusion_auto_create_true').click
  end

  def select_mirrored_specific
    @driver.find_element(:id, 'git_fusion_auto_create_false').click
  end

  def select_private
    @driver.find_element(:id, 'project_visibility_level_0').click
  end

  def select_internal
    @driver.find_element(:id, 'project_visibility_level_10').click
  end

  def select_public
    @driver.find_element(:id, 'project_visibility_level_20').click
  end

  def repo_names
    check_servers_exist
    return [] unless repos_exist?
    text_values = select2_options(@repo_selector)
    text_values.delete_at(0) if text_values[0] == '<Select repository to enable>'
    text_values
  end

  def selected_repo
    check_servers_exist
    select2_selected(@repo_selector)
  end

  def select_repo(repo)
    check_servers_exist
    # For PGL-1255
    # Need to specifically select mirrored_specific to cater for PGL-1255
    # For an unknown reason, the first time you select something using this automation, it doesn't select properly
    # which I can't reproduce manually.
    # Clicking mirrored_auto then mirrored_specific seems to workaround this issue.
    select_mirrored_auto
    select_mirrored_specific
    # end: For PGL-1255
    select2_select(@repo_selector, repo)
  end

  def server_names
    return [] unless servers_exist?
    select2_options(@server_selector)
  end

  def selected_server
    check_servers_exist
    select2_selected(@server_selector)
  end

  def select_server(server)
    check_servers_exist
    select2_select(@server_selector, server)
    wait_for_gf_options_to_load
  end

  private

  def servers_exist?
    wait_for(:id, 'git_fusion_entry')
    @driver.find_elements(:id, 'git_fusion_entry').length > 0
  end

  def check_servers_exist
    fail 'No GF servers have been configured, you cant interact with them' unless servers_exist?
  end

  def repos_exist?
    wait_for_gf_options_to_load
    @driver.find_elements(:id, @repo_selector).length > 0
  end

  def wait_for_gf_options_to_load
    wait_for(:id, 'git_fusion_auto_create_false') if servers_exist?
  end
end
