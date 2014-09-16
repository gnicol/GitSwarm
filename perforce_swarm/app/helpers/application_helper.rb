require Rails.root.join('app', 'helpers', 'application_helper')

module ApplicationHelper
  def current_path?(path)
    controller, action, _ = path.split('#')
    current_controller?(controller) && current_action?(action)
  end
end
