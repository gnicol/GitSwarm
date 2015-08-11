# EE only test
if PerforceSwarm.ee?
  require Rails.root.join('features', 'steps', 'project', 'audit_event')

  class Spinach::Features::AuditEvent < Spinach::FeatureSteps
    step 'I go to "Members"' do
      page.within '.sidebar-wrapper' do
        find(:link, 'Members').trigger('click')
      end
    end

    step 'I visit project "Shop" settings page' do
      page.within '.sidebar-wrapper' do
        find(:link, 'Settings').trigger('click')
      end
    end

    step 'I go to "Audit Events"' do
      page.within '.sidebar-wrapper' do
        find(:link, 'Audit Events').trigger('click')
      end
    end
  end
end
