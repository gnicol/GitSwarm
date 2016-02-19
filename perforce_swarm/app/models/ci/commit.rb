require Rails.root.join('app', 'models', 'ci', 'commit')

module PerforceSwarm
  module Ci
    module CommitExtension
      def skip_ci?
        return true if Gitlab.config.skip_ci
        super
      end
    end
  end
end

module Ci
  class Commit < ActiveRecord::Base
    prepend PerforceSwarm::Ci::CommitExtension
  end
end
