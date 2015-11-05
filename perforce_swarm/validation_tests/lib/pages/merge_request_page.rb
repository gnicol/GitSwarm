require_relative '../page'

class MergeRequestPage < Page
  def initialize(driver)
    super(driver)
    wait_for(:class, 'accept_merge_request', 90)
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:class, 'accept_merge_request']
    elems
  end

  def remove_source_branch(should_be_removed = true)
    checkbox = @driver.find_element(:id, 'should_remove_source_branch')
    checkbox.click if should_be_removed && !checkbox.selected?
    checkbox.click if !should_be_removed && checkbox.selected?
  end

  def accept_merge_request
    LOG.debug('Accepting merge request')
    @driver.find_element(:class, 'accept_merge_request').click
    wait_for(:class, 'issue-box-merged', 90)
  end
end
