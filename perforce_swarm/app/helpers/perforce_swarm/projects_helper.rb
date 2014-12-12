module PerforceSwarm::ProjectsHelper
  def projects_to_simple_json(projects)
    projects.to_json(
      only:    [:id, :name, :path, :visibility_level],
      include: { namespace: { methods: :human_name, only: [:id, :path] } }
    )
  end

  def projects_as_simple_json(projects)
    projects.as_json(
      only:    [:id, :name, :path, :visibility_level],
      include: { namespace: { methods: :human_name, only: [:id, :path] } }
    )
  end
end
