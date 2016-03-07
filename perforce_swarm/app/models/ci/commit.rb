require Rails.root.join('app', 'models', 'ci', 'commit')

module PerforceSwarm
  module Ci
    module CommitExtension
      def skip_ci?
        # undoc per-repo CI override
        super || project.repository.skip_ci?
      end
    end
  end
end

module Ci
  class Commit < ActiveRecord::Base
    prepend PerforceSwarm::Ci::CommitExtension
  end
end
