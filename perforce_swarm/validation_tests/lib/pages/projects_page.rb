require_relative '../page'

class ProjectsPage < LoggedInPage
  def initialize(driver)
    super(driver)
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:link, 'Your Projects']
    elems << [:link, 'Starred Projects']
    elems << [:link, 'Explore Projects']
    elems
  end

  def projects
    projects = @driver.find_elements(:class, 'project-name')
    project_names = []
    projects.each do | proj |
      project_names << proj.text unless proj.text.length <1
    end
    project_names
  end
end
