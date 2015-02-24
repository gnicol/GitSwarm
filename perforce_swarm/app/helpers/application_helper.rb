require Rails.root.join('app', 'helpers', 'application_helper')

module ApplicationHelper
  # Checks the current route using the format 'ControllerName#ActionName'
  # Used as a shorter way of calling current_controller and current_action together
  # Defaults to using current_page? if the route doesn't include a '#'
  def current_route?(route)
    return current_page?(route) unless route.include?('#')

    controller, action, _ = route.split('#')
    current_controller?(controller) && current_action?(action)
  end

  # Override the Gitlab Promo links with our own Perforce links
  def promo_host
    'perforce.com'
  end

  def help_preprocess(category, file)
    # use our over-ride markdown if present, otherwise use their copy
    if File.exist?(Rails.root.join('perforce_swarm', 'doc', category, file))
      content = File.read(Rails.root.join('perforce_swarm', 'doc', category, file))
      return content.gsub('$your_email', current_user.email)
    else
      content = File.read(Rails.root.join('doc', category, file))
      content.gsub!('$your_email', current_user.email)
    end

    # they talk about GitLab EE only features, nuke those lines
    content.gsub!(/^.*GitLab (EE|Enterprise Edition).*$/, '')

    # some pages need more a whitelist update instead of blacklist; do them first and return
    if file == 'maintenance.md'
      content.gsub!(/about (your )?GitLab/, 'about \1GitSwarm')
      content.gsub!('Check GitLab configuration', 'Check GitSwarm configuration')
      content.gsub!('look at our ', 'look at GitLab\'s ')
      return content
    end

    # hit GitLab occurrences that look ok to update
    content = PerforceSwarm::Branding.rebrand(content)

    # try to clarify its not our website
    content.gsub!(/our website/i, "GitLab's website")

    # do a variety of page specific touch-ups

    content.gsub!(/To see a more in-depth overview see the.*$/, '') if file == 'structure.md'

    # the markdown page needs some finesse to avoid taking undue credit
    if file == 'markdown.md'
      content.gsub!('For GitSwarm we developed something we call', 'GitLab developed something called')
      content.gsub!('Here\'s our logo', 'Here\'s GitLab\'s logo')
    end

    # this section is just for EE users; nuke it
    content.gsub!(/## Managing group memberships via LDAP.*?(?!##)/m, '') if file == 'groups.md'

    # unfair to steal their voice on this bit; put it back
    content.gsub!('At GitSwarm we are guilty', 'At GitLab we are guilty') if file == 'gitlab_flow.md'

    # a few lines that refer to GitLab versions that pre-date our usage
    if file == 'ldap.md'
      content.gsub!(/Please note that before version.*$/, '')
      content.gsub!(/The old LDAP integration syntax still works in GitSwarm.*$/, '')
      content.gsub!(/^.*contains LDAP settings in both the old syntax and the new syntax.*$/, '')
    end

    # this is a link to GitLab flow and should stay GitLab
    content.gsub!('[GitSwarm]', '[GitLab]') if file == 'omniauth.md'

    if file == 'custom_hooks.md'
      content.gsub!('As of gitlab-shell version 2.2.0 (which requires GitSwarm 7.5+), GitSwarm', '')
      content.gsub!('administrators can add custom git hooks to any GitSwarm project.', '')
    end

    # the cleanup page only applies to old versions; nuke the link from the index page
    content.gsub!(/^.*Cleaning up Redis sessions.*$/, '') if file == 'README.md' && category == 'operations'

    # return the munged string
    content
  end
end
