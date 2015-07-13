require Rails.root.join('features', 'steps', 'shared', 'project')

module SharedProject
  include Spinach::DSL

  #########################
  # Actions
  #########################

  step 'create a project named "New Project"' do
    fill_in 'project_path', with: 'new-project'
    click_button 'Create project'
  end

  step 'I rename the project "PerforceProject" to "QAProject"' do
    fill_in 'project_name_edit', with: 'QAProject'
    click_button 'Save changes'
  end

  step 'I rename the project "PerforceProject" to a project with a name over 100 characters' do
    fill_in 'project_name_edit', with: long_project_name + long_project_name
    click_button 'Save changes'
  end

  step 'I rename the path of project "PerforceProject" to "PerforceProjectRenamed"' do
    fill_in 'project_path', with: 'PerforceProjectRenamed'
    find(:css, 'input.btn.btn-warning').click
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
    @project = Project.find_by(name: 'PerforceProject')
    @project ||= create(
      :project,
      name:             'PerforceProject',
      namespace:        @user.namespace,
      path:             'perforce_project',
      snippets_enabled: true
    )
    @project.team << [@user, :master]
  end

  step 'project "PerforceProject" has "Tumblr control" open issue' do
    project = Project.find_by(name: 'PerforceProject')
    create(:issue,
           title: 'Tumblr control',
           project: project,
           description: 'automatic post feature',
           author: project.users.first
    )
  end

  step 'project "PerforceProject" has "HipChat" open issue' do
    project = Project.find_by(name: 'PerforceProject')
    create(:issue,
           title: 'HipChat',
           project: project,
           author: project.users.first
    )
  end

  #########################
  # Navigations
  #########################

  step 'I visit project "PerforceProject" issues page' do
    project_perforce = Project.find_by(name: 'PerforceProject')
    visit namespace_project_issues_path(project_perforce.namespace, project_perforce)
  end

  step 'I visit project "PerforceProject" settings page' do
    project_perforce = Project.find_by(name: 'PerforceProject')
    visit edit_namespace_project_path(project_perforce.namespace, project_perforce)
  end

  #########################
  # Pages
  #########################

  step 'I should see the "QAProject" project page' do
    find(:css, 'title').should have_content('QAProject')
    page.should have_content 'git init'
  end

  step 'I should see the "New Project" project page' do
    find(:css, 'title').should have_content('new-project')
    page.should have_content 'git init'
  end

  step 'I should not see project "Internal"' do
    find('.content').should_not have_content 'Internal'
  end

  #########################
  # Variables
  #########################

  def long_project_name
    'long-project-name_long-project-name_long-project-name_long-project-name_long-project-name_long-project-name'
  end
end
