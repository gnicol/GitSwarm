require_relative '../page'

class LoggedInPage < Page
  def initialize(driver, url = nil)
    super(driver)
    goto(url) if url
    # deliberately doesn't verify - leave that for sub-classes to call
  end

  def elements_for_validation
    elems = super
    elems << [:id, 'search'] # search menu
    elems << [:class, 'logout'] # Logout button
    elems
  end

  def logout
    @driver.find_element(:class, 'logout').click
    LoginPage.new(@driver)
  end

  def goto_create_project_page
    # could either try navigating, or just go to the appropriate sub-url.
    uri = URI.parse @driver.current_url
    newuri = "#{uri.scheme}://#{uri.host}/projects/new"
    goto newuri
    CreateProjectPage.new(@driver)
  end

  def goto_project_page(namespace, project_name)
    uri = URI.parse @driver.current_url
    newuri = "#{uri.scheme}://#{uri.host}/#{namespace}/#{project_name}"
    goto newuri
    ProjectPage.new(@driver)
  end

  def goto_projects_page
    uri = URI.parse @driver.current_url
    newuri = "#{uri.scheme}://#{uri.host}/dashboard/projects"
    goto newuri
    ProjectsPage.new(@driver)
  end

  def goto_branches_page(namespace, project_name)
    uri = URI.parse @driver.current_url
    newuri = "#{uri.scheme}://#{uri.host}/#{namespace}/#{project_name}/branches"
    goto newuri
    BranchesPage.new(@driver)
  end

  def goto_merge_request_page(namespace, project_name, merge_request_name)
    uri = URI.parse @driver.current_url
    newuri = "#{uri.scheme}://#{uri.host}/#{namespace}/#{project_name}/merge_requests"
    goto newuri
    mr_links = @driver.find_elements(:link_text, merge_request_name)
    fail("unique merge request not found for #{merge_request_name} : #{mr_links}") unless mr_links.length == 1
    mr_links.first.click
    MergeRequestPage.new(@driver)
  end

  def goto_configure_mirroring_page(namespace, project_name)
    uri = URI.parse @driver.current_url
    newuri = "#{uri.scheme}://#{uri.host}/#{namespace}/#{project_name}/configure_helix_mirroring"
    goto newuri
    ConfigureMirroringPage.new(@driver)
  end

  # attempts to go directly to the configure_mirroring page for a project, expecting to be redirected
  # to the project page itself, containing the error message saying you are not authorized.
  # will fail if this is not the case
  def goto_configure_mirroring_page_expecting_unauthorized(namespace, project_name)
    error_text = 'You do not have permissions to view or modify Helix mirroring settings on this project.'
    uri = URI.parse @driver.current_url
    newuri = "#{uri.scheme}://#{uri.host}/#{namespace}/#{project_name}/configure_helix_mirroring"
    goto newuri
    pp = ProjectPage.new(@driver) # validate we are redirected to the project page
    fail("Expected error not found : #{error_text}") unless page_has_text(error_text)
    pp
  end
end
