module SharedPaths
  include Spinach::DSL
  include RepoHelpers

  step 'I visit project "PerforceProject" page' do
    visit project_path(perforce_project)
  end

  step 'I visit project "PerforceProject" merge requests page' do
    visit project_merge_requests_path(perforce_project)
  end

  def perforce_project
    Project.find_by(name: 'PerforceProject')
  end
end
