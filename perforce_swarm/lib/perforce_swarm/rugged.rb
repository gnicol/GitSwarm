require 'rugged'

module PerforceSwarm
  module RuggedRepository
    # Filter mirror remotes out of the branch listing
    def branches
      super.select do |branch|
        branch.canonical_name !~ %r{^refs/remotes/mirror/}
      end
    end
  end
end

class Rugged::Repository
  prepend PerforceSwarm::RuggedRepository
end
