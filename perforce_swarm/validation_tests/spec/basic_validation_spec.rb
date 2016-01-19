require 'spec_helper'

require_relative '../lib/pages/login_page'
require_relative '../lib/pages/logged_in_page'

describe 'BasicValidationTests', browser: true do
  describe 'login page' do
    it 'should have expected title' do
      LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      expect(@driver.title).to eq('Sign in · GitSwarm')
    end
  end

  describe 'dashboard page' do
    it 'should have expected title' do
      login = LoginPage.new(@driver, CONFIG.get('gitswarm_url'))
      dashboard = login.login(CONFIG.get('gitswarm_username'), CONFIG.get('gitswarm_password'))
      expect(@driver.title).to eq('Projects · Dashboard · GitSwarm')
      dashboard.logout
    end
  end
end
