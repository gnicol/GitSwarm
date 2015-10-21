require_relative '../page'

class BranchesPage < Page
  def initialize(driver)
    super(driver)
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:class, 'btn-create'] # create branch button
    elems
  end

  def available_branches
    elems = @driver.find_element(:class, 'all-branches').find_elements(:tag_name, 'strong')
    branches = []
    elems.each { |br| branches << br.text }
    branches
  end

  def create_branch(new_branch, source_branch)
    url = current_url
    @driver.find_element(:class, 'btn-create').click
    wait_for(:id, 'branch_name')
    @driver.find_element(:id, 'branch_name').send_keys(new_branch)
    @driver.find_element(:id, 'ref').send_keys(source_branch)
    @driver.find_element(:class, 'btn-create').click
    goto(url)
  end

  # Fails if there are no changes in teh branch to merge
  def create_and_accept_merge_request(branch, delete_source = true)
    url = current_url
    # finds the first button which should be merge request - not a great search
    LOG.log('Creating merge request for '+branch)
    @driver.find_element(:class, 'js-branch-'+branch).find_element(:class, 'btn').click
    sleep(1) # this pause seems to be needed before clicking the button.

    fail('There are no changes to merge') if page_has_text("There isn't anything to merge.")

    LOG.log('clicking create button')
    @driver.find_element(:class, 'btn-create').click
    wait_for(:class, 'accept_merge_request')
    LOG.log('opting to delete source branch') if delete_source
    @driver.find_element(id: 'should_remove_source_branch').click if delete_source
    LOG.log('Accepting merge request on '+branch)
    @driver.find_element(:class, 'accept_merge_request').click
    wait_for(:class, 'issue-box-merged', 60)
    goto(url)
  end
end
