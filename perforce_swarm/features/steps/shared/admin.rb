module SharedAdmin
  include Spinach::DSL

  step 'I visit admin "PerforceProject" project page' do
    visit admin_project_path(project)
  end

  step 'I transfer project "PerforceProject" to "QA"' do
    find(:xpath, "//input[@id='namespace_id']").set group.id
    click_button 'Transfer'
  end

  step 'I should see project transferred to group "QA"' do
    page.should have_content 'QA / ' + project.name
    page.should have_content 'Namespace: QA'
  end

  def project
    @project ||= Project.first
  end

  def group
    Group.find_by(name: 'QA')
  end
end
