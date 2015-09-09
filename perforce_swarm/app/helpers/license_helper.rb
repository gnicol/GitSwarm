if PerforceSwarm.ee?
  require Rails.root.join('app', 'helpers', 'license_helper')

  module PerforceSwarm
    module LicenseHelper
      # rebrand GitLab in the license message
      def license_message(signed_in: signed_in?, is_admin: (current_user && current_user.is_admin?))
        @license_message = super.gsub('GitLab', 'GitSwarm')
      end
    end
  end
end

module LicenseHelper
  prepend PerforceSwarm::LicenseHelper if PerforceSwarm.ee?
end
