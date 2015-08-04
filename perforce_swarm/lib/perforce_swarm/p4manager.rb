require 'P4'

module PerforceSwarm
  module P4DManager
    def self.update_p4d_root_password(password)
      p4 = P4.connection
      p4.run('login')
      # not to self: check validation rules between p4d and gitswarm
      p4.input(password)
      p4.run('passwd', 'root')
      p4.disconnect
    end
  end
end
