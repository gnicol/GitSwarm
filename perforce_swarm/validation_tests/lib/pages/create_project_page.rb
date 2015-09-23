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
      elems << [:id, 'git_fusion_repo_name'] # GF repo selector
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
    get_text_options_from_dropdown(repo_selector)
    fail 'The magic double dropdown is messing with this - failing to get text out of the options'
  end

  def selected_repo
    check_servers_exist
    selected_option(repo_selector)
  end

  def select_repo(repo)
    check_servers_exist
    select_option_from_dropdown(repo_selector, repo)
  end

  private

  def server_selector
    @driver.find_element(:id, 'git_fusion_entry')
  end

  def repo_selector
    @driver.find_element(:id, 'git_fusion_repo_name')
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
