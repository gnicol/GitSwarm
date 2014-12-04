require Rails.root.join('features', 'steps', 'shared', 'project')

module SharedProject
  include Spinach::DSL

  #########################
  # Actions
  #########################

  step 'create a project named "New Project"' do
    fill_in 'project_name', with: 'New Project'
    click_button 'Create project'
  end

  step 'I rename the project "PerforceProject" to "QAProject"' do
    fill_in 'project_name_edit', with: 'QAProject'
    click_button 'Save changes'
  end

  step 'I rename the project "PerforceProject" to a project with a name over 100 characters' do
    fill_in 'project_name_edit', with: long_project_name
    click_button 'Save changes'
  end

  step 'I transfer the project "PerforceProject" to another user' do
    user2 = create(:user)
    project_perforce = Project.find_by(name: 'PerforceProject')
    project_perforce.team << [user2, :developer]
  end

  step 'I transfer the project to a "QA" group' do
    create(:group, name: 'QA')
  end

  step 'I remove the project' do
    find(:css, 'a.btn.btn-remove').click
    fill_in 'confirm_name_input', with: 'gitlabhq'
    find(:css, 'input.btn.btn-danger.js-confirm-danger-submit').click
  end

  step 'I archive the project' do
    find(:css, 'a.btn.btn-warning').click
  end

  #########################
  # Data
  #########################

  step 'I own project "PerforceProject"' do
    @project ||= create(:project, name: 'PerforceProject', namespace: @user.namespace, snippets_enabled: true)
    @project.team << [@user, :master]
  end

  #########################
  # Navigations
  #########################

  step 'I visit project "PerforceProject" issues page' do
    project_perforce = Project.find_by(name: 'PerforceProject')
    visit project_issues_path(project_perforce)
  end

  step 'I visit project "PerforceProject" settings page' do
    project_perforce = Project.find_by(name: 'PerforceProject')
    visit edit_project_path(project_perforce)
  end

  #########################
  # Pages
  #########################

  step 'I should see the "New Project" project page' do
    find(:css, 'title').should have_content('New Project')
    page.should have_content 'git init'
  end

  step 'I should not see project "Internal"' do
    find('.content').should_not have_content 'Internal'
  end

  #########################
  # Variables
  #########################

  def long_project_name
    'long-project-name_long-project-name_long-project-name_long-project-name_long-project-name_long-project-name_long-project-name_long-project-name_long-project-name'
  end
end
