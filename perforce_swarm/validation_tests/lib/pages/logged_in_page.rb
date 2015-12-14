require_relative '../page'

class LoggedInPage < Page
  def initialize(driver)
    super(driver)
    # deliberately doesn't verify - leave that for sub-classes to call
  end

  def elements_for_validation
    elems = super
    elems << [:id, 'search'] # search menu
    elems << [:class, 'sidebar-user'] # the user profile
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
end
