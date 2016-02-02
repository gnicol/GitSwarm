module API
  class Internal < Grape::API
    after_validation do
      if options[:path].include?('/allowed')
        project = Project.find_with_namespace(params[:project].chomp('.wiki'))

        # Throw error if repo is mirrored, and the gitswarm user is missing
        if project &&
            PerforceSwarm::Repo.new(project.repository.path_to_repo).mirrored? &&
            !User.find_by(username: 'gitswarm')
          render_api_error!('gitswarm user doesn\'t exist in GitSwarm', 400)
        end
      end
    end

    namespace 'internal' do
      get '/discover' do
        if params[:key_id] && params[:key_id].start_with?('user-')
          user = User.find_by(id: params[:key_id].gsub(/^user\-/, ''))
        else
          user = Key.find(params[:key_id]).user
        end

        present user, with: Entities::UserSafe
      end
    end
  end
end

# The first route attached to a path wins for the API, which is why we declare our version first
require Rails.root.join('lib', 'api', 'internal')
