require_relative 'logged_in_page'

class ProjectPage < LoggedInPage
  HELIX_MIRRORING = 'helix-mirroring'

  def initialize(driver)
    super(driver)
    verify
  end

  def elements_for_validation
    elems = super
    elems << [:class, 'project-home-desc', 45] # project name
    elems << [:class, 'helix-mirrored-status-label']
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
    txt = @driver.find_element(:class, 'helix-mirrored-status-label').text
    return true  if txt == 'Mirrored in Helix'
    return false if txt == 'Not Mirrored in Helix'
    screendump
    LOG.debug("Text of status label was #{txt}")
    fail('Cannot determine if project is Mirrored in Helix - check the screendump to work out why not!')
  end

  def can_configure_mirroring?
    elem = @driver.find_element(:class, HELIX_MIRRORING)
    !elem.attribute(:class).include?('disabled')
  end

  def configure_mirroring
    unless can_configure_mirroring?
      LOG.debug("WARNING: #{HELIX_MIRRORING} button is not enabled for this user")
      screendump
    end
    @driver.find_element(:class, HELIX_MIRRORING).click
    ConfigureMirroringPage.new(@driver)
  end
end
