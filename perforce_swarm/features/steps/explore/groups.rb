require Rails.root.join('features', 'steps', 'explore', 'groups')

class Spinach::Features::ExploreGroups < Spinach::FeatureSteps
  step 'I should not see project "Internal" items' do
    find('.content').should_not have_content "Internal"
  end
end