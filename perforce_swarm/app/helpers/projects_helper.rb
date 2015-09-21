require Rails.root.join('app', 'helpers', 'projects_helper')

module ProjectsHelper
  # Don't linkify the last section of the title, in order to give a larger already
  # To click for the dropdown
  def project_title(project, name = nil, _url = nil)
    namespace_link =
      if project.group
        link_to(simple_sanitize(project.group.name), group_path(project.group))
      else
        owner = project.namespace.owner
        link_to(simple_sanitize(owner.name), user_path(owner))
      end

    project_link = simple_sanitize(project.name)
    project_link = link_to(project_link, project_path(project)) if name

    full_title = namespace_link + ' / ' + project_link
    full_title += ' &middot; '.html_safe + simple_sanitize(name) if name

    content_tag :span do
      full_title
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

  def git_fusion_servers
    return [] unless git_fusion_import_enabled?

    options = []
    servers = gitlab_shell_config.git_fusion.entries
    servers.each do |id, config|
      options.push([config[:url], id])
    end
    servers.empty? ? [] : options_for_select(options, params['git_fusion_entry'])
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
