# This is an override test, so use the parent spec_helper
require 'spec_helper'

describe 'Profile > Preferences' do
  before do
    login_as(:user)
    visit profile_preferences_path
  end
  describe 'User changes their default dashboard' do
    it 'updates their preference', override: true do
      select 'Starred Projects', from: 'user_dashboard'
      click_button 'Save'

      click_link 'js-shortcuts-home'
      expect(page.current_path).to eq starred_dashboard_projects_path

      click_link 'Your Projects'
      expect(page.current_path).to eq dashboard_path
    end
  end
end
