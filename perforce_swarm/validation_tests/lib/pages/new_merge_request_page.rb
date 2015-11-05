require_relative '../page'

class NewMergeRequestPage < Page
  def initialize(driver)
    super(driver)
    sleep(1) # this page needs a moment to load properly
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:class, 'btn-create'] if changes? # create branch button
    elems
  end

  def changes?
    !page_has_text("There isn't anything to merge.")
  end

  def create_merge_request
    fail('There are no changes to merge') unless changes?
    LOG.debug('clicking create button')
    @driver.find_element(:class, 'btn-create').click
    MergeRequestPage.new(@driver)
  end
end
