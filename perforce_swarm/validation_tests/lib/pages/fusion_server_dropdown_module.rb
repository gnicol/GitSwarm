module FusionServerDropdownModule
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

  private

  def servers_exist?
    @driver.find_elements(:id, 'git_fusion_entry').length > 0
  end

  def check_servers_exist
    fail 'No GF servers have been configured, you cant interact with them' unless servers_exist?
  end

  def server_selector
    @driver.find_element(:id, 'git_fusion_entry')
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
end
