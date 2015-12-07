module FusionServerDropdownModule
  def server_names
    check_servers_exist
    get_text_options_from_server_selector
  end

  def select_server(server)
    check_servers_exist
    select_option_from_server_selector(server)
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

  def server_selector
    @driver.find_element(:id, 's2id_git_fusion_entry').find_element(:class, 'select2-choice')
  end

  #
  # takes a 'dropdown' type element and extracts the options from it
  #
  def get_text_options_from_server_selector
    server_selector.click
    container = @driver.find_elements(:class, 'select2-drop-active')[1]
    elements = container.find_elements(:class, 'select2-result-selectable')
    text_values = []
    elements.each do |x|
      text_values << x.text
    end
    @driver.find_element(:id, 'select2-drop-mask').click # de-click the menu
    text_values
  end

  # Selects the provided option from a dropdown.  If option not present, raises error
  def select_option_from_server_selector(option)
    server_selector.click # open the dropdown
    container = @driver.find_elements(:class, 'select2-drop-active')[1]
    elements = container.find_elements(:class, 'select2-result-selectable')
    elements.each do |x|
      next unless x.text==option
      x.click
      return
    end
    fail('Did not find requested server in available servers dropdown: '+option)
  end
end
