module SharedPaths
  include Spinach::DSL
  include RepoHelpers

  step 'I visit project "PerforceProject" page' do
    project = Project.find_by(name: 'PerforceProject')
    visit project_path(project)
  end
end
