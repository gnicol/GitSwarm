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
    gitlab_shell_config.git_fusion.enabled?
  rescue
    # encountering errors around mis-parsed config, empty URLs, etc. all gets treated as if the feature were disabled
    return false
  end

  def git_fusion_server_error
    return nil unless git_fusion_import_enabled?

    # Call the url method on each server to validate the config
    gitlab_shell_config.git_fusion.entries.each { | _id, config | config.url }
    nil
  rescue => e
    return e.message
  end

  def git_fusion_servers(auto_create_default = false)
    return [] unless git_fusion_import_enabled?

    options  = []
    servers  = gitlab_shell_config.git_fusion.entries
    selected = params['git_fusion_entry']
    servers.each do |id, config|
      options.push([config[:url], id])
      # skip setting our selected element if we've already got one, or
      # if the current config entry isn't configured for auto-create, and
      # we're looking for the first one that is
      next if selected || (auto_create_default && !config.auto_create_configured?)
      selected = id
    end
    servers.empty? ? [] : options_for_select(options, selected)
  end

  def git_fusion_repos(repos)
    options = [['<Select repository to enable>', '']]
    repos.each do |name, _description|
      options.push([name, name])
    end
    repos.empty? ? [] : options_for_select(options)
  end

  # note we can't call this gitlab_config as there is already a helper for gitlab-ce's config with that name
  def gitlab_shell_config
    @gitlab_shell_config ||= PerforceSwarm::GitlabConfig.new
  end
end
