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
end
