namespace :perforce_swarm do
  desc "Import Perforce Swarm Data"
  task :import => :environment do
    # need a user to create a project via the service
    admin = User.order(:id).find_by!(admin: true)

    # grab all the projects from p4 so we can turn them into
    # gitlab projects via the create service
    projects = PerforceSwarm::P4.run('keys', '-e', 'swarm-project-*')
    projects.each do |project|
      project = project.fetch('value')
      project = ActiveSupport::JSON.decode(project).symbolize_keys
      project = ::Projects::CreateService.new(
        admin,
        {
          name:         project.fetch(:name),
          description:  project.fetch(:description)
        }
      ).execute
    end
  end
end
