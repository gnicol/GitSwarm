require_relative 'logged_in_page'
require_relative '../page'

class EditFilePage < LoggedInPage
  def initialize(driver)
    super(driver)
    wait_for(:id, 'file_name', 5)
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:id, 'file_name'] # new file name field
    elems << [:id, 'editor'] # conten panel
    elems << [:class, 'js-commit-message'] #
    elems << [:class, 'commit-btn'] # commit changes button
    elems << [:class, 'btn-cancel'] # cancel button
    elems
  end

  def file_name
    get('file_name')
  end

  def file_name=(name)
    set('file_name', name)
  end

  def content=(text)
    # '-'s in the string don't make it into the text field - no clue why.
    fail('I dont know why but this doesnt work if there is a - in the string') if text.include? '-'

    elem = @driver.find_element(:class, 'ace_text-input')
    elem.click
    elem.send_keys([:control, 'a'], :delete)
    elem.send_keys(text)
  end

  def commit_message
    elem = @driver.find_element(:class, 'js-commit-message').last
    elem.attribute('value')
  end

  def commit_message=(message)
    # For some unknown reason, there are 2 instances with this ID on the page. The first is not displayed
    elem = @driver.find_elements(:class, 'js-commit-message').last
    elem.click
    elem.send_keys(message)
  end

  def commit_change
    @driver.find_element(:class, 'commit-btn').click
    LoggedInPage.new(@driver)
  end

  private

  def get(identifier)
    elem = @driver.find_element(:id, identifier)
    elem.attribute('value')
  end

  def set(identifier, text)
    elem = @driver.find_element(:id, identifier)
    elem.clear
    elem.send_keys(text)
  end
end
