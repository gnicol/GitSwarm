require Rails.root.join('app', 'helpers', 'projects_helper')

module ProjectsHelper
  # Don't linkify the last section of the title, so there is a larger click
  # area for the dropdown. Plus the link would just take you to your current page.
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

    full_title  = namespace_link + ' / ' + project_link
    full_title += ' &middot; '.html_safe + simple_sanitize(name) if name

    content_tag :span do
      full_title
    end
  end

  def mirroring_errors(project, user)
    # Git Fusion integration is explicitly disabled
    tooltip = <<-EOM
      GitSwarm's Helix Git Fusion integration is disabled.<br />
      To enable Helix mirroring, please have an admin enable the Git Fusion integration.
    EOM
    return tooltip.html_safe unless git_fusion_enabled?

    # no Git Fusion entries found in the config
    tooltip = <<-EOM
      GitSwarm's Helix Git Fusion integration is enabled, however no Git Fusion instances have been configured.<br />
      To enable Helix mirroring, please have an admin configure at least one Git Fusion instance.
    EOM
    return tooltip.html_safe unless git_fusion_instances?

    # include details if there is a configuration error with one or more Git Fusion servers
    tooltip = <<-EOM
      GitSwarm's Helix Git Fusion integration is enabled, however there is a configuration error:<br />
      #{ERB::Util.html_escape(git_fusion_server_error)}
    EOM
    return tooltip.html_safe if git_fusion_server_error

    # this project is already mirrored
    return '' if project.git_fusion_mirrored?

    # no Git Fusion config entries have auto create enabled, or it is mis-configured
    tooltip = <<-EOM
      None of the Helix Git Fusion instances GitSwarm knows about are configured for 'auto create'.<br />
      To enable Helix mirroring, please have an admin configure at least one Git Fusion instance for auto create.
    EOM
    return tooltip.html_safe unless mirroring_configured?

    # user does not have adequate permissions to enable mirroring
    tooltip = <<-EOM
      GitSwarm is configured for Helix mirroring, but you lack permissions to enable it for this project.<br />
      To enable Helix mirroring, you must be a project 'master' or an 'admin'.
    EOM
    return tooltip.html_safe unless mirroring_permitted?(project, user)

    nil
  end

  def mirroring_tooltip(project, user, for_button = false)
    errors = mirroring_errors(project, user)
    return errors if errors

    # all good in the 'hood - tooltip is slightly different for the button vs the text below the clone URL
    return 'Click to get mirroring!' if for_button
    'Click "Helix Mirroring" above to get mirroring!'
  end

  # time (as a string) of the last successful fetch from Git Fusion, or false if no timestamp is present
  def git_fusion_last_fetched(project)
    PerforceSwarm::Mirror.last_fetched(project.repository.path_to_repo).strftime('%F %T %z')
  rescue
    return false
  end

  # the error being reported by Git Fusion mirroring, or false if there are no errors
  def git_fusion_last_fetch_error(project)
    PerforceSwarm::Mirror.last_fetch_error(project.repository.path_to_repo)
  end

  # returns the rendered (sans password) URL for a currently or previously mirrored project
  def git_fusion_url(project)
    # project is currently mirrored
    url = nil
    if project.git_fusion_mirrored?
      url = PerforceSwarm::Repo.new(project.repository.path_to_repo).mirror_url
    elsif project.git_fusion_repo.present?
      url = PerforceSwarm::GitFusionRepo.resolve_url(project.git_fusion_repo).to_s
    end
    return '' unless url
    url
  rescue
    return ''
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

  def git_fusion_servers(default_first_auto_create: false)
    return [] unless git_fusion_enabled?

    options  = []
    servers  = gitlab_shell_config.git_fusion.entries
    selected = params['git_fusion_entry']
    servers.each do |id, config|
      options.push(["#{id} (#{config[:url]})", id])
      # skip setting our selected element if we've already got one, or
      # if the current config entry isn't configured for auto-create, and
      # we're looking for the first one that is
      next if selected || (default_first_auto_create && !config.auto_create_configured?)
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

  def helix_mirroring_button(project, user)
    # wrapper for tooltip
    haml_tag(:span,
             data:  { title: mirroring_tooltip(project, user, true), html: 'true' },
             class: 'has_tooltip mirror-button-wrapper') do
      # parameters for an enable button
      can_mirror = mirroring_permitted?(@project, current_user) && mirroring_configured?
      attributes = { class: 'btn btn-save' + (can_mirror ? '' : ' disabled') }

      # add the button at the appropriate haml indent level
      haml_concat(
          link_to(configure_helix_mirroring_namespace_project_path(project.namespace, project), attributes) do
            haml_concat(icon('helix-icon-white'))
            haml_concat('Helix Mirroring')
          end
      )
    end
  end
end
