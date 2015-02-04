require 'rugged'

module PerforceSwarm
  module RuggedRepository
    # Filter mirror remotes out of the branch listing
    def branches
      super.select { |branch| branch.remote_name != 'mirror' }
    end
  end
end

class Rugged::Repository
  prepend PerforceSwarm::RuggedRepository
end
