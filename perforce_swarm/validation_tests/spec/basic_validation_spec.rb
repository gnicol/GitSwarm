require 'spec_helper'

require_relative '../lib/page'

describe 'BasicValidationTests', browser: true do
  describe 'login page', Mirroring: true do
    it 'should have expected title' do
      LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      expect(@driver.title).to eq('Sign in · GitSwarm')
    end
  end

  describe 'dashboard page', Mirroring: true do
    it 'should have expected title' do
      login = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      dashboard = login.login(CONFIG.get(CONFIG::GS_USER), CONFIG.get(CONFIG::GS_PASSWORD))
      expect(@driver.title).to eq('Projects · Dashboard · GitSwarm')
      dashboard.logout
    end
  end

  describe 'GitSwarm root password synced to Perforce', PasswordSync: true do
    before(:all) do
      # this sets up a GSAPIHelper that should work regardless of password changes
      # it holds the 'magic code' to allow changes, even if the password changes
      @api_helper = GitSwarmAPIHelper.new(CONFIG.get(CONFIG::GS_URL),
                                          CONFIG.get(CONFIG::GS_USER),
                                          CONFIG.get(CONFIG::GS_PASSWORD))
    end

    after(:all) do
      @api_helper.update_admin_password(CONFIG.get(CONFIG::GS_USER), CONFIG.get(CONFIG::GS_PASSWORD))
    end

    let(:new_password) { 'new-password-123' }
    let(:root_user)    { 'root' }

    it 'should have expected p4 root password to match existing Gitswarm root password' do
      if CONFIG.get(CONFIG::GS_USER) != root_user || CONFIG.get(CONFIG::P4_USER) != root_user
        skip "Skipping test because GitSwarm & P4 admin users in config.yml are not '#{root_user}'"
      end
      if CONFIG.get(CONFIG::GS_PASSWORD) != CONFIG.get(CONFIG::P4_PASSWORD)
        fail("Failing test because GitSwarm & P4 admin users passwords are not configured to be the same
             #{CONFIG.get(CONFIG::GS_PASSWORD)} #{CONFIG.get(CONFIG::P4_PASSWORD)}")
      end
      # Verify that auto provisioned p4 'root' user's password matches GitSwarm root user's password
      verify_p4_password(CONFIG.get(CONFIG::P4_PORT), root_user, CONFIG.get(CONFIG::GS_PASSWORD))
    end

    it 'should have expected p4 root password to match updated Gitswarm root password' do
      if CONFIG.get(CONFIG::GS_USER) != root_user || CONFIG.get(CONFIG::P4_USER) != root_user
        skip "Skipping test because GitSwarm & P4 admin users in config.yml are not '#{root_user}'"
      end

      # Reset password from the configured pasword to the new password
      @api_helper.update_admin_password(root_user, new_password)

      # Verify that p4 root user password is new password
      verify_p4_password(CONFIG.get(CONFIG::P4_PORT), root_user, new_password)

      # Finally, reset the GitSwarm root user password back to its original password
      @api_helper.update_admin_password(root_user, CONFIG.get(CONFIG::GS_PASSWORD))

      # And verify that p4 root user password is back to its original password
      verify_p4_password(CONFIG.get(CONFIG::P4_PORT), root_user, CONFIG.get(CONFIG::GS_PASSWORD))
    end
  end

  def verify_p4_password(p4_port, user, password)
    p4_dir = Dir.mktmpdir('P4-', tmp_client_dir)
    p4_depot_path = "#{CONFIG.get(CONFIG::P4_DEPOT_ROOT)}..."
    @p4 = P4Helper.new(p4_port, user, password, p4_dir, p4_depot_path)
    expect(@p4.connect).to include("User #{user} logged in.")
  end
end
