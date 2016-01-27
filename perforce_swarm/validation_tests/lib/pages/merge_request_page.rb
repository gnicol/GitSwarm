require_relative 'logged_in_page'

class MergeRequestPage < LoggedInPage
  OPEN         = 'Open'
  CLOSED       = 'Closed'
  MERGED       = 'Merged'

  def initialize(driver)
    super(driver)
    wait_for_page_to_load
    verify
  end

  def wait_for_page_to_load
    sleep(1)
    wait_for(:class, 'merge-request-details')
  end

  def elements_for_validation
    elems = super
    elems << [:class, 'merge-request-details']
    elems << [:class, 'issuable-context-form']
    elems
  end

  def remove_source_branch(should_be_removed = true)
    wait_for(:id, 'should_remove_source_branch', 90)
    checkbox = @driver.find_element(:id, 'should_remove_source_branch')
    checkbox.click if should_be_removed && !checkbox.selected?
    checkbox.click if !should_be_removed && checkbox.selected?
  end

  def accept_merge_request
    accept_merge_and_wait
    # Once the page reloads we should see the issue box merged
    wait_for(:class, 'status-box-merged', 90)
    fail('MR state is not CLOSED as expected') unless state == MERGED
  end

  def accept_merge_request_expecting_failure
    accept_merge_and_wait
    wait_for_text(:class, 'mr-state-widget', 'Something went wrong during merge', 90)
    fail('MR state is not OPEN as expected') unless state == OPEN
  end

  def state
    @driver.find_element(:class, 'status-box').text
  end

  def can_accept_merge
    page_has_element(:class, 'accept_merge_request')
  end

  private

  def accept_merge_and_wait
    LOG.debug('Accepting merge request')
    wait_for(:class, 'accept_merge_request', 90)
    @driver.find_element(:class, 'accept_merge_request').click
    # Ensure that are are merging
    wait_for_text(:class, 'mr-widget-body', 'Merge in progress')
    # Wait until we are no longer merging anymore
    wait_for_no_text(:class, 'mr-widget-body', 'Merge in progress', 180)
  end
end
