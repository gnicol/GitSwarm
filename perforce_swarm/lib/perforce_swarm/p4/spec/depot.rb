module PerforceSwarm
  module P4
    module Spec
      class Depot
        # given a connection and either a single depot or an array of them, this method returns either a boolean
        # true/false for the existence of a single depot or a list of depots that exist if given more than one
        def self.exists?(depots, connection)
          found   = []
          depots  = [*depots]
          connection.run('depots').each do |depot|
            next unless depots.include?(depot['name'])
            found.push(depot['name'])
          end
          # for single existence return whether we found one, otherwise return all (if any) found
          return depots.length == 1 ? found.length > 0 : found
        rescue
          # command bombed for whatever reason, so return false/empty
          return depots.length == 1 ? false : []
        end
      end
    end
  end
end
