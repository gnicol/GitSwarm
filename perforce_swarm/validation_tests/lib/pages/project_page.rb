require_relative 'logged_in_page'
require_relative '../page'

class ProjectPage < Page
  def initialize(driver)
    super(driver)
    wait_for_clone
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:class, 'git-protocols'] # project name
    elems
  end

  private

  def wait_for_clone
    wait_for(:class, 'git-protocols', 45)
  end
end
