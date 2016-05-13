require Rails.root.join('features', 'steps', 'project', 'snippets')

class Spinach::Features::ProjectSnippets < Spinach::FeatureSteps
  step 'project "Shop" have "Snippet one" snippet' do
    create(:project_snippet,
           title: 'Snippet one',
           content: 'Test content',
           file_name: 'snippet.rb',
           project: project,
           author: project.users.first)
    # the step 'I visit snippet page "Snippet one"' was failing due to project.namespace
    # being nil. We found that by requesting project.namespace before that step runs
    # makes it more likely to succeed
    # GitSwarm 2016.2, Community 8.8.0pre
    _namespace = project.namespace
  end
end
