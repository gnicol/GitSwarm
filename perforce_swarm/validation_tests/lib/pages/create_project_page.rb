# Adding in the require_relative 'logged_in_page' line to ensure that the autoloader does not fail
# with the error "uninitialized constant LoggedInPage (NameError)"
require_relative 'logged_in_page'
require_relative '../page'
require_relative '../project'
require_relative 'select2_module'

class CreateProjectPage < LoggedInPage
  include Select2Module
  ID_REPO_SELECTOR              = 's2id_git_fusion_repo_name'
  ID_SERVER_SELECTOR            = 's2id_git_fusion_entry'
  ID_NAMESPACE_SELECTOR         = 's2id_project_namespace_id'
  ID_MIRRORORING_DISABLED       = 'git_fusion_repo_create_type_disabled'
  ID_MIRRORORING_AUTO_CREATE    = 'git_fusion_repo_create_type_auto-create'
  ID_MIRRORORING_IMPORT         = 'git_fusion_repo_create_type_import-repo'
  ID_GF_ENTRY                   = 'git_fusion_entry'
  ID_PROJECT_PATH               = 'project_path'
  NAME_COMMIT                   = 'commit'
  ID_PROJECT_VIS_PRIVATE        = 'project_visibility_level_0'
  ID_PROJECT_VIS_INTERNAL       = 'project_visibility_level_10'
  ID_PROJECT_VIS_PUBLIC         = 'project_visibility_level_20'

  def initialize(driver)
    super(driver)
    wait_for_gf_options_to_load
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:id, ID_PROJECT_PATH] # project name
    elems << [:name, NAME_COMMIT] # create project button
    if servers_exist?
      elems << [:id, ID_MIRRORORING_DISABLED] # Not mirrored
      elems << [:id, ID_MIRRORORING_AUTO_CREATE] # auto-create mirrored
      elems << [:id, ID_MIRRORORING_IMPORT] # mirror existing
      elems << [:id, ID_GF_ENTRY] # GF server selection dropdown
    end
    elems
  end

  def project_name(name)
    field = @driver.find_element(:id, ID_PROJECT_PATH)
    field.clear
    field.send_keys(name)
  end

  def namespace(namespace)
    select2_select(ID_NAMESPACE_SELECTOR, namespace)
  end

  def namespaces
    select2_options(ID_NAMESPACE_SELECTOR)
  end

  def selected_namespace
    select2_selected(ID_NAMESPACE_SELECTOR)
  end

  def create_project_and_wait_for_clone
    @driver.find_element(:name, NAME_COMMIT).click
    ProjectPage.new(@driver)
  end

  def select_mirrored_none
    @driver.find_element(:id, ID_MIRRORORING_DISABLED).click
  end

  def select_mirrored_auto
    @driver.find_element(:id, ID_MIRRORORING_AUTO_CREATE).click
  end

  def select_mirrored_specific
    @driver.find_element(:id, ID_MIRRORORING_IMPORT).click
  end

  def select_private
    @driver.find_element(:id, ID_PROJECT_VIS_PRIVATE).click
  end

  def select_internal
    @driver.find_element(:id, ID_PROJECT_VIS_INTERNAL).click
  end

  def select_public
    @driver.find_element(:id, ID_PROJECT_VIS_PUBLIC).click
  end

  def repo_names
    check_servers_exist
    return [] unless repos_exist?
    text_values = select2_options(ID_REPO_SELECTOR)
    text_values.delete_at(0) if text_values[0] == '<Select repository to enable>'
    text_values
  end

  def selected_repo
    check_servers_exist
    select2_selected(ID_REPO_SELECTOR)
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
    select2_select(ID_REPO_SELECTOR, repo)
  end

  def server_names
    return [] unless servers_exist?
    select2_options(ID_SERVER_SELECTOR)
  end

  def selected_server
    check_servers_exist
    select2_selected(ID_SERVER_SELECTOR)
  end

  def select_server(server)
    check_servers_exist
    select2_select(ID_SERVER_SELECTOR, server)
    wait_for_gf_options_to_load
  end

  private

  def servers_exist?
    wait_for(:id, ID_GF_ENTRY)
    @driver.find_elements(:id, ID_GF_ENTRY).length > 0
  end

  def check_servers_exist
    fail 'No GF servers have been configured, you cant interact with them' unless servers_exist?
  end

  def repos_exist?
    wait_for_gf_options_to_load
    @driver.find_elements(:id, ID_REPO_SELECTOR).length > 0
  end

  def wait_for_gf_options_to_load
    wait_for(:id, ID_MIRRORORING_DISABLED) if servers_exist?
  end
end
