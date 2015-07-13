# EE specific test
if PerforceSwarm.ee?
  require Rails.root.join('features', 'steps', 'admin', 'email')

  class Spinach::Features::AdminEmail < Spinach::FeatureSteps
    step 'unsubscribed email is sent' do
      mail = ActionMailer::Base.deliveries.last
      expect(mail.text_part.body.decoded).to include(
        'You have been unsubscribed from receiving GitSwarm administrator notifications.'
      )
    end
  end
end
