require_relative '../page'

class MergeRequestPage < Page
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
    LOG.debug('Accepting merge request')
    wait_for(:class, 'accept_merge_request', 90)
    @driver.find_element(:class, 'accept_merge_request').click
    wait_for(:class, 'issue-box-merged', 120)
  end
end
