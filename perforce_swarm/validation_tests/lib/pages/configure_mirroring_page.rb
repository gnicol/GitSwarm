require_relative 'logged_in_page'
require_relative '../page'
require_relative 'fusion_server_dropdown_module'

class ConfigureMirroringPage < LoggedInPage
  include FusionServerDropdownModule

  def initialize(driver)
    super(driver)
    wait_for_page_to_load
    verify
  end

  def elements_for_validation
    elems = super
    if servers_exist?
      elems << [:class, 'btn-create'] # Launch Mirroring button
    end
    elems
  end

  def mirror_project_and_wait
    @driver.find_element(:class, 'btn-create').click
    ProjectPage.new(@driver)
  end

  private

  def wait_for_page_to_load
    sleep(1) # this seems needed to let the servers_ext check pass
    wait_for(:class, 'btn-create') if servers_exist?
  end
end
