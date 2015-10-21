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

  def mirrored?(project)
    project.git_fusion_repo.present?
  end

  def mirroring_tooltip(project, user, for_button = false)
    # Git Fusion integration is explicitly disabled
    tooltip = <<-EOM
      GitSwarm's Helix Git Fusion integration is disabled.<br />
      To enable Helix mirroring, please have an admin enable the Git Fusion integration.
    EOM
    return tooltip unless git_fusion_enabled?

    # no Git Fusion entries found in the config
    tooltip = <<-EOM
      GitSwarm's Helix Git Fusion integration is enabled, however no Git Fusion instances have been configured.<br />
      To enable Helix mirroring, please have an admin configure at least one Git Fusion instance.
    EOM
    return tooltip unless git_fusion_instances?

    # include details if there is a configuration error with one or more Git Fusion servers
    tooltip = <<-EOM
      GitSwarm's Helix Git Fusion integration is enabled, however there is a configuration error:<br />
      #{ERB::Util.html_escape(git_fusion_server_error)}
    EOM
    return tooltip if git_fusion_server_error

    # this project is already mirrored
    return '' if mirrored?(project)

    # no Git Fusion config entries have auto create enabled, or it is mis-configured
    tooltip = <<-EOM
      None of the Helix Git Fusion instances GitSwarm knows about are configured for 'auto create'.<br />
      To enable Helix mirroring, please have an admin configure at least one Git Fusion instance for auto create.
    EOM
    return tooltip unless mirroring_configured?

    # user does not have adequate permissions to enable mirroring
    tooltip = <<-EOM
      GitSwarm is configured for Helix mirroring, but you lack permissions to enable it for this project.<br />
      To enable Helix mirroring, you must be a project 'master' or an 'admin'.
    EOM
    return tooltip unless mirroring_permitted?(project, user)

    # all good in the 'hood - tooltip is slightly different for the button vs the text below the clone URL
    return 'Click to get mirroring!' if for_button
    'Click "Mirror in Helix" above to get mirroring!'
  end

  # boolean as to whether there are configured Git Fusion instances in the config
  def git_fusion_instances?
    !git_fusion_servers.empty?
  rescue
    false
  end

  # boolean as to whether the current user is permitted to enable mirroring on the given project
  def mirroring_permitted?(project, user)
    user && user.can?(:admin_project, project)
  end

  # returns true if there is at least one configured Git Fusion repository that supports convention-based mirroring
  # note that we are doing pre-flight style checks with the config only, and not actually connecting to Helix at this
  # point
  def mirroring_configured?
    return false unless git_fusion_instances?

    # ensure that at least one entry is configured for convention-based mirroring
    gitlab_shell_config.git_fusion.entries.each do |_id, entry|
      return true if entry.auto_create_configured?
    end
    # we didn't find one, or there are no entries at all
    false
  rescue
    # if we encountered an exception with the above, mirroring is definitely not possible
    return false
  end

  def git_fusion_enabled?
    gitlab_shell_config.git_fusion.enabled?
  rescue
    # as the code sits, this is not likely to occur, but we're being defensive anyway
    return false
  end

  def git_fusion_server_error
    return nil unless git_fusion_enabled?

    # Call the url method on each server to validate the config
    gitlab_shell_config.git_fusion.entries.each { | _id, config | config.url }
    nil
  rescue => e
    return e.message
  end

  def git_fusion_servers
    return [] unless git_fusion_enabled?

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
