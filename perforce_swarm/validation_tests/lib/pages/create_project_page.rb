# Adding in the require_relative 'logged_in_page' line to ensure that the autoloader does not fail
# with the error "uninitialized constant LoggedInPage (NameError)"
require_relative 'logged_in_page'
require_relative '../page'
require_relative 'fusion_server_dropdown_module'

class CreateProjectPage < LoggedInPage
  include FusionServerDropdownModule

  def initialize(driver)
    super(driver)
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
    repo_selector.click
    container = @driver.find_element(:class, 'select2-drop-active')
    elements = container.find_elements(:class, 'select2-result-selectable')
    text_values = []
    elements.each { |x| text_values << x.text }
    @driver.find_element(:id, 'select2-drop-mask').click # de-click the menu
    text_values.delete_at(0) if text_values[0] == '<Select repository to enable>'
    text_values
  end

  def selected_repo
    repo_selector.text
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

    repo_selector.click # open the dropdown
    container = @driver.find_element(:class, 'select2-drop-active')
    elements = container.find_elements(:class, 'select2-result-selectable')
    elements.each do |x|
      next unless x.text==repo
      x.click
      return true
    end
    fail('Did not find requested repo in available repos dropdown: '+repo)
  end

  private

  def repo_selector
    @driver.find_element(:id, 's2id_git_fusion_repo_name').find_element(:class, 'select2-choice')
  end

  def wait_for_gf_options_to_load
    wait_for(:id, 'git_fusion_auto_create_false') if servers_exist?
  end
end
