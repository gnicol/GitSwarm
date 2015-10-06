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

  def mirrored?(project)
    project.git_fusion_repo.present?
  end

  def button_tooltip(project, user)
    configured = mirroring_configured?
    permitted  = mirroring_permitted?(project, user)

    # mirroring is neither configured nor permitted
    tooltip = 'Gitswarm must be connected to Helix by an admin and '\
    'project must be mirrored by the project owner or an admin to '\
    "use Helix clients.  Click 'not mirrored in helix' below for more info."
    return tooltip unless configured || permitted

    # mirroring is configured but not permitted
    tooltip = 'An admin must enable interaction with helix clients. '\
    "Click 'not mirrored in helix' below for more info."
    return tooltip unless permitted

    # mirroring is permitted, but not configured
    'Project owner or admin must enable mirroring on this project to connect Helix clients' unless configured
  end

  def not_mirrored_tooltip(project, user)
    configured = mirroring_configured?
    permitted  = mirroring_permitted?(project, user)

    # mirroring is neither configured nor permitted
    tooltip = 'To mirror this project in Helix versioning engine, an admin must connect ' \
    'GitSwarm to a working Helix Git Fusion instance, and select a path for ' \
    'newly mirrored projects. Please have an admin see these directions.'
    return tooltip unless configured || permitted

    # mirroring is configured but not permitted
    tooltip = 'Project must be mirrored in Helix to use Helix clients. ' \
    'Only the project owner or an admin can enable mirroring.' \
    'Please ask the project owner to see this page.'
    return tooltip unless permitted

    # mirroring is permitted, but not configured
    'In order to mirror the project in Helix so it can be accessed by Helix '\
    'clients, an admin must connect Gitswarm to a working Helix GitFusion.'\
    'Please have an admin see this page.' unless configured
  end

  # boolean as to whether the current user is permitted to enable mirroring on the given project
  def mirroring_permitted?(project, user)
    user.can?(:admin_project, project)
  end

  # returns true if there is at least one configured Git Fusion repository that supports convention-based mirroring
  # note that we are doing pre-flight style checks with the config only, and not actually connecting to Helix at this
  # point
  def mirroring_configured?
    return false unless git_fusion_import_enabled?

    # for each entry, ensure that it at least one that is configured for convention-based mirroring
    gitlab_shell_config.git_fusion.entries.each do |_id, entry|
      return true if entry.auto_create_configured?
    end
    # we didn't find one, or there are no entries at all
    false
  rescue
    # if we encountered an exception with the above, mirroring is definitely not possible
    return false
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
