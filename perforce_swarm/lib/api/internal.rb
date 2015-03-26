module API
  class Internal < Grape::API
    after_validation do
      # Throw error if request includes the check_service_user flag, and the user is missing
      if parse_boolean(params['check_service_user']) == true && !User.find_by(username: 'gitswarm')
        render_api_error!('gitswarm user doesn\'t exist in GitSwarm', 400)
      end
    end
  end
end

# The first route attached to a path wins for the API, which is why we declare our version first
require Rails.root.join('lib', 'api', 'internal')
