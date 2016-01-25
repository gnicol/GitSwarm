require_relative 'logged_in_page'

class NewMergeRequestPage < LoggedInPage
  def initialize(driver)
    super(driver)
    wait_for_page_to_load
    verify
  end

  def wait_for_page_to_load
    sleep(1)
    wait_for(:css, 'form.merge-request-form')
  end

  def elements_for_validation
    elems = super
    elems << [:css, 'form.merge-request-form'] # new merge request form
    elems << [:css, 'form.merge-request-form .btn-create'] if changes? # create branch button
    elems << [:id, 'merge_request_title'] # title for the merge request
    elems
  end

  def changes?
    !page_has_text("There isn't anything to merge.")
  end

  def create_merge_request(title)
    fail('There are no changes to merge') unless changes?
    elem = @driver.find_element(:id, 'merge_request_title')
    elem.clear
    elem.send_keys(title)
    LOG.debug('clicking create button')
    @driver.find_element(:css, 'form.merge-request-form .btn-create').click
    MergeRequestPage.new(@driver)
  end
end
