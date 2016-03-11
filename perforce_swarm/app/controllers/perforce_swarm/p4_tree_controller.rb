module PerforceSwarm
  class P4TreeController < ApplicationController
    DEPOT_TYPE_WHITELIST ||= %w(local stream)
    DEPOT_NAME_BLACKLIST ||= %w(.git-fusion)

    def show
      return render_404 unless params['fusion_server'] && params['path']
      gitlab_shell_config = PerforceSwarm::GitlabConfig.new
      return render_404 unless gitlab_shell_config.git_fusion.enabled?

      git_fusion = gitlab_shell_config.git_fusion.entry(params['fusion_server'])

      p4 = PerforceSwarm::P4::Connection.new(git_fusion)
      p4.login

      respond_to do |format|
        format.json do
          render json: get_dirs(p4, params['path'])
        end
        format.all { render_404 }
      end
    ensure
      p4.disconnect if p4
    end

    private

    def get_dirs(connection, path = nil)
      dirs = []
      if path == '#'
        connection.run('depots').each do |depot|
          next if DEPOT_NAME_BLACKLIST.include?(depot['name']) || !DEPOT_TYPE_WHITELIST.include?(depot['type'])

          depot_dir = {
            id:       "//#{depot['name']}",
            text:     depot['name'],
            type:     "depot-#{depot['type']}",
            data:     {},
            children: true
          }

          dirs << depot_dir
        end
      else
        # Grab basic depot information
        depot = PerforceSwarm::P4::Spec::Depot.fetch(connection, PerforceSwarm::P4::Spec::Depot.id_from_path(path))
        current_depth = path.sub(%r{^//}, '').split('/').length

        if depot['Type'] == 'stream' && current_depth == depot['numericStreamDepth']
          # Find the streams
          connection.run('streams', "#{path}/...").each do |stream_info|
            dirs << {
              id:       "#{path}/#{stream_info['Name']}",
              text:     stream_info['Name'],
              type:     'folder-stream',
              data:     { streamType: stream_info['Type'], streamParent: stream_info['Parent'] },
              children: true
            }
          end
        else
          # Find the dirs
          connection.run('dirs', "#{path}/*").each do |dir_info|
            dir_name = File.basename(dir_info['dir'])

            dirs << {
              id:       "#{path}/#{dir_name}",
              text:     dir_name,
              type:     'folder',
              children: true
            }
          end
        end
      end
      dirs
    end
  end
end
