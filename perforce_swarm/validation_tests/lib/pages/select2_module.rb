module Select2Module
  def select2_selected(select2_id)
    @driver.find_element(:id, select2_id).find_element(:class, 'select2-choice').text
  end

  # The id is a string like 's2id_git_fusion_entry'
  def select2_options(select2_id)
    @driver.find_element(:id, select2_id).find_element(:class, 'select2-choice').click
    text_values = []
    elements = @driver.find_elements(:class, 'select2-result-selectable')
    elements.each do |x|
      text_values << x.text
    end
    @driver.find_element(:id, 'select2-drop-mask').click # de-click the menu
    text_values
  end

  # Selects the provided option from a dropdown (checked with 'starts_with?' for server names)
  # If option not present, raises error
  # The id is a string like 's2id_git_fusion_entry'
  def select2_select(select2_id, option)
    @driver.find_element(:id, select2_id).find_element(:class, 'select2-choice').click
    elements = @driver.find_elements(:class, 'select2-result-selectable')
    elements.each do |x|
      next unless x.text.start_with?(option)
      x.click
      return
    end
    fail('Did not find requested option : '+option)
  end
end
