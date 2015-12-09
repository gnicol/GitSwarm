require 'spec_helper'

require_relative '../lib/page'

describe 'BasicValidationTests', browser: true do
  describe 'login page', localGF: true, externalGF: true do
    it 'should have expected title' do
      LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      expect(@driver.title).to eq('Sign in | GitSwarm')
    end
  end

  describe 'dashboard page', localGF: true, externalGF: true do
    it 'should have expected title' do
      login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      dashboard = login.login(CONFIG.get('gitswarm_username'), CONFIG.get('gitswarm_password'))
      expect(@driver.title).to eq('Projects | Dashboard | GitSwarm')
      dashboard.logout
    end
  end

  describe 'GitSwarm root password synced to Perforce', localGF: true do
    let(:new_password) { 'new-password-123' }

    it 'should have expected p4 root password to match existing Gitswarm root password' do
      if CONFIG.get('gitswarm_username') == 'root'
        # Note that the p4 user is 'root'
        # Verify that p4 'root' user's password matches GitSwarm root user's password
        @p4 = P4Helper.new(CONFIG.get('p4_port'), 'root', CONFIG.get('gitswarm_password'))
        expect(@p4.login).to include('User root logged in.')
      else
        LOG.log("Please ensure GitSwarm admin user '#{CONFIG.get('gitswarm_username')}' is set as 'root' for this test")
      end
    end

    it 'should have expected p4 root password to match updated Gitswarm root password' do
      if CONFIG.get('gitswarm_username') == 'root'
        login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
        password_reset = login.click_login_with_password_reset(CONFIG.get('gitswarm_username'),
                                                               CONFIG.get('gitswarm_password'),
                                                               "#{CONFIG.get('gitswarm_url')}/profile/password/edit"
        )
        # Reset password from CONFIG.get('gitswarm_password') to 'new_password'
        password_reset.set_password(CONFIG.get('gitswarm_password'), new_password)

        # Verify that p4 root user password is 'new_password'
        @p4 = P4Helper.new(CONFIG.get('p4_port'), 'root', new_password)
        expect(@p4.login).to include('User root logged in.')

        # Finally, reset the GitSwarm root user password back to its original password CONFIG.get('gitswarm_password')
        login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
        password_reset = login.click_login_with_password_reset(CONFIG.get('gitswarm_username'),
                                                               new_password,
                                                               "#{CONFIG.get('gitswarm_url')}/profile/password/edit"
        )
        password_reset.set_password(new_password, CONFIG.get('gitswarm_password'))
      else
        LOG.log("Please ensure GitSwarm admin user '#{CONFIG.get('gitswarm_username')}' is set as 'root' for this test")
      end
    end
  end
end
