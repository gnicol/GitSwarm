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
end
