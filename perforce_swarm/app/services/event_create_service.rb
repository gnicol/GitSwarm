require Rails.root.join('app', 'services', 'event_create_service')

module PerforceSwarm
  module EventCreateServiceExtension
    # TODO: this method is the cause of a race condition in side-by-side diff comment spinach tests
    # TODO: please fix
    def create_event(project, current_user, status, attributes = {})
      return unless current_user

      attributes.reverse_merge!(
        project: project,
        action: status,
        author_id: current_user.id
      )
      Event.create(attributes)
    end
  end
end

class EventCreateService
  prepend PerforceSwarm::EventCreateServiceExtension
end
