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

  # This looks for a link to add the README on the page.  The exact text can change if there are other files in
  # the repo, so using partial_link_text.  Will fail if a readme already exists in the project
  def add_readme
    fail 'No README link on this project page - README probably already exists' unless
        page_has_element(:partial_link_text, 'README')
    @driver.find_element(:partial_link_text, 'README').click
    EditFilePage.new(@driver)
  end

  def add_file(filename, branchname = 'master')
    new_url = current_url + '/new/'+branchname+'?file_name=' + filename
    goto(new_url)
    EditFilePage.new(@driver)
  end

  def mirrored_in_helix?
    page_has_element(:link_text, 'Mirrored in Helix')
  end

  def click_mirror_in_helix
    fail 'project already mirrored' if mirrored_in_helix?
    @driver.find_element(:link_text, 'Helix Mirroring').click
    ConfigureMirroringPage.new(@driver)
  end

  private

  def wait_for_clone
    wait_for(:class, 'git-protocols', 45)
  end
end
