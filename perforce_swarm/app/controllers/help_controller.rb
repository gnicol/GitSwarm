require Rails.root.join('app', 'controllers', 'help_controller')

module PerforceSwarm
  # Override the CE help controller to search the swarm directory for files
  module HelpControllerExtension
    def render_doc
      if File.exist?(Rails.root.join('perforce_swarm', 'doc', @filepath + '.md'))
        render 'show.html.haml'
      else
        super
      end
    end

    def send_file_data
      path = Rails.root.join('perforce_swarm', 'doc', "#{@filepath}.#{@format}")
      if File.exist?(path)
        send_file(path, disposition: 'inline')
      else
        super
      end
    end
  end
end

class HelpController
  prepend PerforceSwarm::HelpControllerExtension
  skip_before_filter :authenticate_user!,
                     :reject_blocked
end
