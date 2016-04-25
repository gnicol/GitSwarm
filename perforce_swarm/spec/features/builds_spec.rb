require 'spec_helper'

describe 'Builds' do
  let(:artifacts_file) { fixture_file_upload(Rails.root + 'spec/fixtures/banana_sample.gif', 'image/gif') }

  before do
    login_as(:user)
    @commit = FactoryGirl.create :ci_commit
    @build = FactoryGirl.create :ci_build, commit: @commit
    @project = @commit.project
    @project.team << [@user, :developer]
  end

  describe 'POST /:project/builds/:id/cancel_all', override: true do
    before do
      @build.run!
      visit namespace_project_builds_path(@project.namespace, @project)
      within('.nav-controls') do
        click_link 'Cancel running'
      end
    end

    it { expect(page).to have_selector('.nav-links li.active', text: 'All') }
    it { expect(page).to have_content 'canceled' }
    it { expect(page).to have_content @build.short_sha }
    it { expect(page).to have_content @build.ref }
    it { expect(page).to have_content @build.name }
    it { expect(page).to_not have_link 'Cancel running' }
  end
end
