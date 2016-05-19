class Spinach::Features::RevertMergeRequests < Spinach::FeatureSteps
  include LoginHelpers
  include GitlabRoutingHelper

  step 'I revert the changes directly' do
    page.within('#modal-revert-commit') do
      uncheck 'create_merge_request'
      find(:button, 'Revert').trigger('click')
    end
  end
end
