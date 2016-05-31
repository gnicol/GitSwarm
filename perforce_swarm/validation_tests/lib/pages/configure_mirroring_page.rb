require_relative '../page'
require_relative 'logged_in_page'
require_relative 'project_page'
require_relative 'fusion_server_dropdown_module'

class ConfigureMirroringPage < LoggedInPage
  include FusionServerDropdownModule

  DISABLED_TEXT           = 'Mirroring for this project has been disabled.'.freeze
  ENABLED_TEXT            = 'This project is currently mirrored to'.freeze
  NEVER_MIRRORED_TEXT     = 'Select a Helix server to mirror the project to'.freeze
  MIRRORING_DISABLED_TEXT = 'GitSwarm\'s Helix Git Fusion integration is disabled.'.freeze
  REENABLE_BUTTON_TEXT    = 'Re-enable Helix Mirroring'.freeze
  ENABLE_BUTTON_TEXT      = 'Launch Mirroring'.freeze
  DISABLE_BUTTON_TEXT     = 'Disable Helix Mirroring'.freeze

  def initialize(driver)
    super(driver)
    wait_for_page_to_load
    verify
  end

  def elements_for_validation
    # many options for what might be here, leave it to use of the page to verify
    super
  end

  def mirror_project_and_wait
    click_and_accept(:class, 'btn-create')
    ProjectPage.new(@driver)
  end

  def can_disable?
    page_has_text(DISABLE_BUTTON_TEXT)
  end

  def can_enable?
    page_has_text(ENABLE_BUTTON_TEXT)
  end

  def can_reenable?
    page_has_text(REENABLE_BUTTON_TEXT)
  end

  def enable_mirroring
    unless can_enable?
      screendump
      raise "Enable button text not there : #{ENABLE_BUTTON_TEXT} "
    end
    click_and_accept(:class, 'btn-save')
    ProjectPage.new(@driver)
  end

  def reenable_mirroring
    unless can_reenable?
      screendump
      raise "Reenable button text not there : #{REENABLE_BUTTON_TEXT} "
    end
    click_and_accept(:class, 'btn-save')
    ProjectPage.new(@driver)
  end

  def disable_mirroring
    unless can_disable?
      screendump
      raise "Disable button text not there : #{DISABLE_BUTTON_TEXT} "
    end
    click_and_accept(:class, 'btn-save')
    ProjectPage.new(@driver)
  end

  private

  def click_and_accept(by, value)
    @driver.execute_script('window.confirm = function(){return true;}')
    @driver.find_element(by, value).click
  end

  def wait_for_page_to_load
    sleep(2)
    if page_has_text(NEVER_MIRRORED_TEXT)
      wait_for(:id, 'git_fusion_entry', 60)
      wait_for(:class, 'btn-create')
    end
  end
end
