require Rails.root.join('app', 'helpers', 'projects_helper')

module ProjectsHelper
  # Only linkify the group part of the project title
  def project_title(project)
    if project.group
      content_tag :span do
        link_to(simple_sanitize(project.group.name), group_path(project.group)) + ' / ' + simple_sanitize(project.name)
      end
    else
      owner = project.namespace.owner
      content_tag :span do
        link_to(simple_sanitize(owner.name), user_path(owner)) + ' / ' + simple_sanitize(project.name)
      end
    end
  end

  def git_fusion_import_enabled?
    !git_fusion_url.nil?
  end

  def git_fusion_url
    PerforceSwarm::GitlabConfig.new.git_fusion_entry['url']
  end

  def git_fusion_help
    # TODO: Put a link here that's actually helpful
    'http://www.google.com'
  end

  def git_fusion_repos
    options = [['', '']]
    repos   = PerforceSwarm::Repo.list
    repos.each do |name, _description|
      options.push([name, name])
    end
    repos.empty? ? [] : options_for_select(options)
  end
end
