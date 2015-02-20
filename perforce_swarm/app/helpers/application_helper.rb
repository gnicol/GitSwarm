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
    if File.exists?(Rails.root.join('peforce_swarm', 'doc', category, file))
      content = File.read(Rails.root.join('peforce_swarm', 'doc', category, file))
    else
      content = File.read(Rails.root.join('doc', category, file))
    end

    # do the work of the standard view
    content.gsub!('$your_email', current_user.email)

    # make some page specific tweaks
    content.gsub!(/To see a more in-depth overview see the.*$/, '') if file == 'structure.md'

    # they talk about GitLab EE only features, nuke those lines
    content.gsub!(/^.*GitLab EE.*$/, '')

    # rename to GitSwarm and ensure external links are theirs not ours
    content.gsub!('GitLab', 'GitSwarm')
    content.gsub!(/our website/i, "GitLab's website")

    # return the munged string
    content
  end
end
