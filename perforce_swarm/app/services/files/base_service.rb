require Rails.root.join('app', 'services', 'files', 'base_service')

module PerforceSwarm
  module FilesBaseService
    def execute
      begin
        super
      rescue Rugged::ObjectError => ex
        # Present a nicer error if the user just needs to reload
        if ex.message =~ /current tip is not the first parent/
          error('This file was already changed on this branch. Try again.')
        else
          raise ex
        end
      end
    rescue => ex
      Gitlab::AppLogger.error ex.message
      error('Something went wrong. Your changes may not have been committed')
    end
  end
end

class Files::BaseService
  prepend PerforceSwarm::FilesBaseService
end
