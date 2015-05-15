require Rails.root.join('app', 'controllers', 'help_controller')

module PerforceSwarm
  # Override the CE help controller to search the swarm directory for files
  module HelpControllerExtension
    def show
      category = clean_path_info(path_params[:category])
      file = path_params[:file]

      respond_to do |format|
        format.any(:markdown, :md, :html) do
          swarm_path = Rails.root.join('perforce_swarm', 'doc', category, "#{file}.md")
          path       = Rails.root.join('doc', category, "#{file}.md")
          if File.exist?(swarm_path)
            @markdown = File.read(swarm_path)
            render 'show.html.haml'
          elsif File.exist?(path)
            @markdown = view_context.help_preprocess(category, file)
            render 'show.html.haml'
          else
            # Force template to Haml
            render 'errors/not_found.html.haml', layout: 'errors', status: 404
          end
        end

        # Allow access to images in the doc folder
        format.any(:png, :gif, :jpeg) do
          swarm_path = Rails.root.join('perforce_swarm', 'doc', category, "#{file}.#{params[:format]}")
          path       = Rails.root.join('doc', category, "#{file}.#{params[:format]}")
          if File.exist?(swarm_path)
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
  skip_before_filter :authenticate_user!,
                     :reject_blocked
end
