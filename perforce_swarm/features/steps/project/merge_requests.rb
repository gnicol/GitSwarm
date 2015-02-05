require Rails.root.join('features', 'steps', 'project', 'merge_requests')

class Spinach::Features::ProjectMergeRequests < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths
  include SharedProject
  include Spinach::DSL
  include LoginHelpers

  step 'I should see last push widget' do
    page.should have_content 'You pushed to fix'
    page.should have_link 'Create Merge Request'
  end

  step 'I click "Create Merge Request" link' do
    click_link 'Create Merge Request'
  end

  step 'I click link "New Merge Request"' do
    click_link 'New Merge Request'
  end

  step 'I see prefilled new Merge Request page' do
    current_path.should eq new_project_merge_request_path(@project)
    find('#merge_request_target_project_id').value.should eq @project.id.to_s
    find('#merge_request_source_branch').value.should eq 'fix'
    find('#merge_request_target_branch').value.should eq 'master'
  end

  step 'I click button "Assign to me"' do
    click_link 'Assign to me'
  end

  step 'I submit new merge request "Jira Integration"' do
    fill_in 'merge_request_title', with: 'Jira Integration'
    click_button 'Submit merge request'
  end

  step 'I submit new merge request "Dependency Fix"' do
    fill_in 'merge_request_title', with: 'Dependency Fix'
    click_button 'Submit merge request'
  end
  step 'I should see "Jira Integration" in merge requests' do
    page.should have_content 'Jira Integration'
  end

  step 'gitlab user "Sam"' do
    create(:user, name: 'Sam')
  end

  step '"Sam" is "Shop" developer' do
    user = User.find_by(name: 'Sam')
    project = Project.find_by(name: 'Shop')
    project.team << [user, :developer]
  end

  step 'I should be redirected to sign in page' do
    current_path.should == new_user_session_path
  end

  step 'I sign in as "Sam"' do
    login_with(User.find_by(name: 'Sam'))
  end

  step 'I fill out a "Compare branches for new Merge Request"' do
    select @project.path_with_namespace, from: 'merge_request_source_project_id'
    select @project.path_with_namespace, from: 'merge_request_target_project_id'
    select 'fix', from: 'merge_request_source_branch'
    select 'master', from: 'merge_request_target_branch'
    click_button 'Compare branches'
  end

  step 'merge request "Dependency Fix" is mergeable' do
    merge_request = MergeRequest.find_by(title: 'Dependency Fix')
    merge_request.mark_as_mergeable
  end

  step 'merge request is mergeable' do
    page.should have_button 'Accept Merge Request'
  end

  step 'I accept this merge request' do
    Gitlab::Satellite::MergeAction.any_instance.stub(
        merge!: true
    )

    click_button 'Accept Merge Request'
  end

  step 'I should see merged request' do
    page.find('.issue-box').should have_content 'Merged'
  end

  step 'I visit merge request page "Dependency Fix"' do
    mr = MergeRequest.find_by(title: 'Dependency Fix')
    visit project_merge_request_path(mr.target_project, mr)
    page.find('h3.issue-title').should have_content 'Dependency Fix'
  end

  step 'I should see project branch "Fix"' do
    page.find('.js-branch-fix').should have_content 'fix'
  end
end
