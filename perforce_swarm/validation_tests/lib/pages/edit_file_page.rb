require_relative 'logged_in_page'
require_relative 'project_page'

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
    elems << [:id, 'commit_message'] #
    elems << [:id, 'new_branch'] #
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
    elem = @driver.find_element(:class, 'ace_text-input')
    elem.click
    elem.send_keys([:control, 'a'], :delete)
    elem.send_keys(text)
  end

  def commit_message
    get('commit_message')
  end

  def commit_message=(message)
    set('commit_message', message)
  end

  def branch
    get('new_branch')
  end

  def branch=(branch)
    set('new_branch', branch)
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
