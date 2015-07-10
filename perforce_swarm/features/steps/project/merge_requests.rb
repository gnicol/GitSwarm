require Rails.root.join('features', 'steps', 'project', 'merge_requests')

class Spinach::Features::ProjectMergeRequests < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths
  include SharedProject
  include Spinach::DSL
  include LoginHelpers

  step 'I click link "New Merge Request"' do
    ancestor = page.find('.issue-search-form + div')
    ancestor.should have_link 'New Merge Request'
    ancestor.click_link 'New Merge Request'
  end

  step 'I should see last push widget' do
    page.should have_content 'You pushed to fix'
    page.should have_link 'Create Merge Request'
  end

  step 'I click "Create Merge Request" link' do
    click_link 'Create Merge Request'
  end

  step 'I see prefilled new Merge Request page' do
    current_path.should eq new_namespace_project_merge_request_path(@project.namespace, @project)
    find('input#merge_request_target_project_id').value.should eq @project.id.to_s
    find('input#merge_request_source_branch').value.should eq 'fix'
    find('input#merge_request_target_branch').value.should eq 'master'
  end

  step 'I click button "Assign to me"' do
    click_link 'Assign to me'
  end

  step 'I submit new merge request "Jira Integration"' do
    page.find('h3.page-title').should have_content 'New merge request'
    fill_in 'merge_request_title', with: 'Jira Integration'
    click_button 'Submit new merge request'
  end

  step 'I submit new merge request "Dependency Fix"' do
    page.should have_selector('.merge-request-form-info')
    page.find('h3.page-title').should have_content 'New merge request'
    fill_in 'merge_request_title', with: 'Dependency Fix'
    click_button 'Submit new merge request'
  end

  step 'I should see "Jira Integration" in merge requests' do
    project = Project.find_by(name: 'Shop')
    current_path.should eq namespace_project_merge_requests_path(project.namespace, project)
    page.should have_content 'Jira Integration'
  end

  step 'there is a gitlab user "Sam"' do
    create(:user, name: 'Sam')
  end

  step '"Sam" is "Shop" developer' do
    user = User.find_by(name: 'Sam')
    project = Project.find_by(name: 'Shop')
    project.team << [user, :developer]
  end

  step 'I should be redirected to sign in page' do
    current_path.should eq new_user_session_path
  end

  step 'I sign in as "Sam"' do
    login_with(User.find_by(name: 'Sam'))
  end

  step 'I fill out a "Compare branches for new Merge Request"' do
    page.find('.lead').should have_content 'Compare branches for new Merge Request'
    select @project.path_with_namespace, from: 'merge_request_source_project_id'
    select @project.path_with_namespace, from: 'merge_request_target_project_id'
    select 'fix', from: 'merge_request_source_branch'
    page.find('.mr_source_commit').should have_selector('.commit')
    select 'master', from: 'merge_request_target_branch'
    page.find('.mr_target_commit').should have_selector('.commit')
    click_button 'Compare branches'
  end

  step 'merge request "Dependency Fix" is mergeable' do
    merge_request = MergeRequest.find_by(title: 'Dependency Fix')
    merge_request.project.satellite.create
    merge_request.mark_as_mergeable
  end

  step 'I visit merge request page "Dependency Fix"' do
    mr = MergeRequest.find_by(title: 'Dependency Fix')
    visit namespace_project_merge_request_path(mr.target_project.namespace, mr.target_project, mr)
    page.find('h2.issue-title').should have_content 'Dependency Fix'
  end

  step 'I should see project branch "Fix"' do
    page.find('.js-branch-fix').should have_content 'fix'
    project = Project.find_by(name: 'Shop')
    current_path.should eq namespace_project_branches_path(project.namespace, project)
  end

  step 'I accept this merge request' do
    module PerforceSwarm::GitlabSatelliteMergeAction
      def merge!(_merge_commit_message = nil)
        true
      end
    end

    page.within '.mr-state-widget' do
      click_button 'Accept Merge Request'
    end
  end

  step 'I click link "All"' do
    page.within '.content-wrapper' do
      click_link 'All'
    end
  end
end
