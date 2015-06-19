require Rails.root.join('features', 'steps', 'project', 'project')

class Spinach::Features::Project < Spinach::FeatureSteps
  step 'I should not see "Snippets" button' do
    find('.content').should_not have_link 'Snippets'
  end
end
