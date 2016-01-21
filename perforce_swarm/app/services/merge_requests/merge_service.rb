require Rails.root.join('app', 'services', 'merge_requests', 'merge_service')

module PerforceSwarm
  module MergeServiceExtensions
    def execute(merge_request)
      # Force a fetch from mirror before merging
      merge_request.check_if_can_be_merged
      super
    end
  end
end

class MergeRequests::MergeService
  prepend PerforceSwarm::MergeServiceExtensions
end
