require 'spec_helper'

require_relative '../lib/pages/login_page'
require_relative '../lib/pages/logged_in_page'
require_relative '../lib/page'

describe 'BasicValidationTests', browser: true do
  describe 'login page' do
    it 'should have expected title' do
      LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      expect(@driver.title).to eq('Sign in | GitSwarm')
    end
  end

  describe 'dashboard page' do
    it 'should have expected title' do
      login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      dashboard = login.login(CONFIG.get('gitswarm_username'), CONFIG.get('gitswarm_password'))
      expect(@driver.title).to eq('Projects | Dashboard | GitSwarm')
      dashboard.logout
    end
  end

  describe 'GitSwarm root password synced to Perforce' do
    it 'should have expected p4 root password to match existing Gitswarm root password' do
      # Note that the p4 user is 'root'
      # Verify that p4 'root' user's password matches GitSwarm password
      @p4 = P4Helper.new(CONFIG.get('p4_port'), 'root', CONFIG.get('gitswarm_password'))
      expect(@p4.login).to include('User root logged in.')
    end

    it 'should have expected p4 root password to match updated Gitswarm root password' do
      login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      password_reset = login.click_login_expecting_password_reset(CONFIG.get('gitswarm_username'),
                                                                  CONFIG.get('gitswarm_password'),
                                                                  "#{CONFIG.get('gitswarm_url')}/profile/password/edit"
      )
      # Reset password from CONFIG.get('gitswarm_password') to 'testing123'
      password_reset.set_password(CONFIG.get('gitswarm_password'), 'testing123')

      # Verify that p4 root user password is 'testing123'
      @p4 = P4Helper.new(CONFIG.get('p4_port'), 'root', 'testing123')
      expect(@p4.login).to include('User root logged in.')

      # Finally, reset the GitSwarm root user password back to its original password CONFIG.get('gitswarm_password')
      login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      password_reset = login.click_login_expecting_password_reset(CONFIG.get('gitswarm_username'),
                                                                  'testing123',
                                                                  "#{CONFIG.get('gitswarm_url')}/profile/password/edit"
      )
      password_reset.set_password('testing123', CONFIG.get('gitswarm_password'))
    end
  end
end
