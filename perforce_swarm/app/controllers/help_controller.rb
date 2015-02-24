require Rails.root.join('app', 'controllers', 'help_controller')

module PerforceSwarm
  # Override the CE help controller to handle non-Markdown files
  # (e.g. images) within the /doc path
  module HelpControllerExtension
    def show
      @category = params[:category]
      @file     = params[:file]
      extension = request.path_parameters[:format]

      # calculate the intended root and the requested path
      doc_path  = File.realpath(Rails.root.join('doc'))
      file_path = Rails.root.join('doc', @category, @file)

      # if we have a non-md extension try to render it as an image
      if !extension.blank? && extension != 'md'
        begin
          asset_path = File.realpath("#{file_path}.#{extension}")
        rescue Errno::ENOENT
          asset_path = false
        end

        if asset_path && asset_path.start_with?(doc_path)
          send_file(
              asset_path,
              x_sendfile:   true,
              type:         request.format,
              disposition:  'inline'
          )
          return
        end

        render nothing: true, status: 404
      end

      # looks like we have a markdown file; ensure its under the right path and render
      begin
        md_path = File.realpath("#{file_path}.md")
      rescue Errno::ENOENT
        md_path = false
      end

      if md_path && md_path.start_with?(doc_path)
        render 'show'
        return
      end

      # otherwise, show the appropriate error
      not_found!
    end
  end
end

class HelpController
  prepend PerforceSwarm::HelpControllerExtension
end
