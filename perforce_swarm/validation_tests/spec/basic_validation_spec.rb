require 'spec_helper'

require_relative '../lib/pages/login_page'
require_relative '../lib/pages/logged_in_page'

describe 'BasicValidationTests', browser: true do
  describe 'login page' do
    it 'should have expected title' do
      LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      expect(@driver.title).to eq('Sign in | GitSwarm')
    end
  end

  describe 'dashboard page' do
    it 'should have expected title' do
      login = LoginPage.new(@driver, CONFIG.get(CONFIG::GS_URL))
      dashboard = login.login(CONFIG.get(CONFIG::GS_USER), CONFIG.get(CONFIG::GS_PASSWORD))
      expect(@driver.title).to eq('Projects | Dashboard | GitSwarm')
      dashboard.logout
    end
  end
end
