require_relative 'logged_in_page'
require_relative 'project_page'

class CreateProjectPage < LoggedInPage
  attr_reader :has_gf_servers

  def initialize(driver)
    super(driver)
    @has_gf_servers = page_has_element(:id, 'git_fusion_entry')
    wait_for_gf_options_to_load
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:id, 'project_path'] # project name
    elems << [:name, 'commit'] # create project button
    if @has_gf_servers
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

  def server_names
    check_servers_exist
    get_text_options_from_dropdown(server_selector)
  end

  def selected_server
    check_servers_exist
    selected_option(server_selector)
  end

  def select_server(server)
    check_servers_exist
    select_option_from_dropdown(server_selector, server)
    wait_for_gf_options_to_load
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
    found = false
    elements.each do |x|
      if x.text==repo
        x.click
        found = true
        break
      end
    end
    fail('Did not find repo in dropdown: '+repo) unless found # de-click the menu
  end

  private

  def server_selector
    @driver.find_element(:id, 'git_fusion_entry')
  end

  def repo_selector
    @driver.find_element(:id, 's2id_git_fusion_repo_name').find_element(:class, 'select2-choice')
  end

  def check_servers_exist
    fail 'No GF servers have been configured, you cant interact with them' unless @has_gf_servers
  end
  #
  # takes a 'dropdown' type element and extracts the options from it
  #
  def get_text_options_from_dropdown(dropdown)
    text_values = []
    dd = Selenium::WebDriver::Support::Select.new(dropdown)
    opts = dd.options
    opts.each { |x| text_values << x.text }
    text_values
  end

  def get_options_from_dropdown(dropdown)
    dropdown.find_elements(:tag_name, 'option')
  end

  # Selects the provided option from a dropdown.  If option not present, raises error
  def select_option_from_dropdown(dropdown, option)
    if get_text_options_from_dropdown(dropdown).include? option
      Selenium::WebDriver::Support::Select.new(dropdown).select_by(:text, option)
    else
      fail 'option not available in dropdown : ' + option
    end
  end

  # returns the currently selected option
  def selected_option(dropdown)
    Selenium::WebDriver::Support::Select.new(dropdown).first_selected_option.text
  end

  def wait_for_gf_options_to_load
    wait_for(:id, 'git_fusion_auto_create_false') if @has_gf_servers
  end
end
