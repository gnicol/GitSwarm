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
    gitlab_shell_config.git_fusion.enabled? && git_fusion_url
  rescue
    # encountering errors around mis-parsed config, empty URLs, etc. all gets treated as if the feature were disabled
    return false
  end

  def git_fusion_url
    gitlab_shell_config.git_fusion.entry['url']
  rescue
    false
  end

  def git_fusion_repos
    options = [['<Select repo to enable>', '']]
    repos   = PerforceSwarm::GitFusionRepo.list
    repos.each do |name, _description|
      options.push([name, name])
    end
    repos.empty? ? [] : options_for_select(options)
  rescue
    # @todo: look for actual errors and provide a message
    return []
  end

  # note we can't call this gitlab_config as there is already a helper for gitlab-ce's config with that name
  def gitlab_shell_config
    @gitlab_shell_config ||= PerforceSwarm::GitlabConfig.new
  end
end
