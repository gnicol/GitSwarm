module SharedPaths
  include Spinach::DSL
  include RepoHelpers

  step 'I visit project "PerforceProject" page' do
    visit project_path(perforce_project)
  end

  step 'I visit project "PerforceProject" blob file page' do
    visit project_blob_path(perforce_project, File.join(sample_commit.id, sample_blob.path))
  end

  step 'I visit project "PerforceProject" branches page' do
    visit project_branches_path(perforce_project)
  end

  step 'I visit project "PerforceProject" commit page' do
    visit project_commits_path(perforce_project, perforce_project.repository.root_ref, limit: 1)
  end

  step 'I visit project "PerforceProject" compare refs page' do
    visit project_compare_index_path(perforce_project)
  end

  step 'I visit project "PerforceProject" deploy keys page' do
    visit project_deploy_keys_path(perforce_project)
  end

  step 'I visit edit project "PerforceProject" page' do
    visit edit_project_path(perforce_project)
  end

  step 'I visit project "PerforceProject" files page' do
    visit project_tree_path(perforce_project, root_ref)
  end

  step 'I visit project "PerforceProject" hooks page' do
    visit project_hooks_path(perforce_project)
  end

  step 'I visit project "PerforceProject" issues page' do
    visit project_issues_path(perforce_project)
  end

  step 'I visit project "PerforceProject" merge request page' do
    visit project_merge_requests_path(perforce_project)
  end

  step 'I visit project "PerforceProject" network page' do
    Network::Graph.stub(max_count: 10)
    visit project_network_path(perforce_project, root_ref)
  end

  step 'I visit project "PerforceProject" protected branches page' do
    visit project_protected_branches_path(perforce_project)
  end

  step 'I visit project "PerforceProject" snippets page' do
    visit project_snippets_path(perforce_project)
  end

  step 'I visit project "PerforceProject" tags page' do
    visit project_tags_path(perforce_project)
  end

  step 'I visit project "PerforceProject" wiki page' do
    visit project_wiki_path(perforce_project, :home)
  end

  def perforce_project
    Project.find_by(name: 'PerforceProject')
  end
end
