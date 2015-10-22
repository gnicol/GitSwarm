require 'rugged'

module PerforceSwarm
  module RuggedBranchCollection
    # Filter remote branches out of the branch listing by default
    def each(filter = :local)
      super
    end
  end
end

class Rugged::BranchCollection
  prepend PerforceSwarm::RuggedBranchCollection
end
