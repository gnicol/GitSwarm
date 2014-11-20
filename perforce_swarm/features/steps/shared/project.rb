module SharedProject
  include Spinach::DSL

  # Create a specific project called "PerforceProject"
  step 'I own project "PerforceProject"' do
    @project ||= create(:project, name: 'PerforceProject', namespace: @user.namespace, snippets_enabled: true)
    @project.team << [@user, :master]
  end

  step 'I visit project "PerforceProject" issues page' do
    project_perforce = Project.find_by(name: 'PerforceProject')
    visit project_issues_path(project_perforce)
  end

  step 'I visit project "PerforceProject" settings page' do
    project_perforce = Project.find_by(name: 'PerforceProject')
    visit edit_project_path(project_perforce)
  end

  step 'I rename the project "PerforceProject" to "QAProject"' do
    fill_in 'project_name', with: 'QAProject'
    click_button 'Save changes'
  end

  step 'create a project named "New Project"' do
    fill_in 'project_name', with: 'New Project'
    click_button 'Create project'
  end

  step 'I should see the "New Project" project page' do
    find(:css, 'title').should have_content('New Project')
    page.should have_content 'git init'
  end
end
