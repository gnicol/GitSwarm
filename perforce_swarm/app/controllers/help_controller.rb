require Rails.root.join('app', 'controllers', 'help_controller')

module PerforceSwarm
  # Override the GitLab help controller to search the
  # perforce_swarm directory for files
  module HelpControllerExtension
    def show
      @category = clean_path_info(path_params[:category])
      @file = path_params[:file]

      respond_to do |format|
        format.any(:markdown, :md, :html) do
          # Note: We are purposefully NOT using `Rails.root.join`
          swarm_path    = File.join(Rails.root, 'perforce_swarm', 'doc-ce', @category, "#{@file}.md")
          swarm_ee_path = File.join(Rails.root, 'perforce_swarm', 'doc-ee', @category, "#{@file}.md")
          path          = File.join(Rails.root, 'doc', @category, "#{@file}.md")
          if PerforceSwarm.ee? && File.exist?(swarm_ee_path)
            @markdown = File.read(swarm_ee_path)
            render 'show.html.haml'
          elsif File.exist?(swarm_path)
            @markdown = File.read(swarm_path)
            render 'show.html.haml'
          elsif File.exist?(path)
            @markdown = PerforceSwarm::Help.preprocess(@category, @file)
            render 'show.html.haml'
          else
            # Force template to Haml
            render 'errors/not_found.html.haml', layout: 'errors', status: 404
          end
        end

        # Allow access to images in the doc folder
        format.any(:png, :gif, :jpeg, :svg) do
          # Note: We are purposefully NOT using `Rails.root.join`
          swarm_path    = File.join(Rails.root, 'perforce_swarm', 'doc-ce', @category, "#{@file}.#{params[:format]}")
          swarm_ee_path = File.join(Rails.root, 'perforce_swarm', 'doc-ee', @category, "#{@file}.#{params[:format]}")
          path          = File.join(Rails.root, 'doc', @category, "#{@file}.#{params[:format]}")
          if PerforceSwarm.ee? && File.exist?(swarm_ee_path)
            send_file(swarm_ee_path, disposition: 'inline')
          elsif File.exist?(swarm_path)
            send_file(swarm_path, disposition: 'inline')
          elsif File.exist?(path)
            send_file(path, disposition: 'inline')
          else
            head :not_found
          end
        end

        # Any other format we don't recognize, just respond 404
        format.any { head :not_found }
      end
    end
  end
end

class HelpController
  prepend PerforceSwarm::HelpControllerExtension
end
