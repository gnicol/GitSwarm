module SharedAdmin
  include Spinach::DSL

  step 'I visit admin "PerforceProject" project page' do
    project_perforce = Project.find_by(name: 'PerforceProject')
    visit admin_namespace_project_path(project_perforce.namespace, project_perforce)
  end

  step 'I should see the admin user page' do
    page.body.should have_content('User Activity')
    find(:css, 'ul.nav.navbar-nav').should have_content('Admin Area')
  end

  step 'I should see the Admin area page' do
    page.find(:css, '.admin-dashboard').should have_content('New User')
  end

  step 'I should see the admin user settings page' do
    find(:css, '.page-title').should have_content('Profile Settings')
    find(:css, 'ul.nav.navbar-nav').should have_content('Admin Area')
  end

  step 'I transfer project "PerforceProject" to "QA"' do
    find(:xpath, "//input[@id='new_namespace_id']").set group.id
    click_button 'Transfer'
  end

  step 'I should see project "PerforceProject" transferred to group "QA"' do
    project_perforce = Project.find_by(name: 'PerforceProject')
    page.should have_content 'QA / ' + project_perforce.name
    page.should have_content 'Namespace: QA'
  end

  step 'I destroy "PerforceProject"' do
    find(:css, '.btn-remove').click
  end

  def project
    @project ||= Project.first
  end

  def group
    Group.find_by(name: 'QA')
  end
end
