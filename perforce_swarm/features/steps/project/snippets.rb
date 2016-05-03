require Rails.root.join('features', 'steps', 'project', 'snippets')

class Spinach::Features::ProjectSnippets < Spinach::FeatureSteps
  step 'project "Shop" have "Snippet one" snippet' do
    create(:project_snippet,
           title: 'Snippet one',
           content: 'Test content',
           file_name: 'snippet.rb',
           project: project,
           author: project.users.first)
    # prime namespace
    _foo = project.namespace
  end
end
