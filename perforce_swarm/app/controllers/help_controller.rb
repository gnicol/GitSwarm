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
            @markdown = help_preprocess(category, file)
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

    def help_preprocess(category, file)
      content = File.read(Rails.root.join('doc', category, "#{file}.md"))

      # they talk about GitLab EE only features, nuke those lines
      content.gsub!(/^.*GitLab (EE|Enterprise Edition).*$/, '')

      content.gsub!(/about (your )?GitLab/, 'about \1GitSwarm')
      content.gsub!('Check GitLab configuration', 'Check GitSwarm configuration')
      content.gsub!('look at our ', 'look at GitLab\'s ')

      # hit GitLab occurrences that look ok to update
      content = PerforceSwarm::Branding.rebrand(content)

      # try to clarify its not our website
      content.gsub!(/our website/i, "GitLab's website")

      # fix example links value
      content.gsub!(/(your-)?gitlab.example.com/, '\1gitswarm.example.com')

      # replace /etc/gitlab with /etc/gitswarm but leave /opt/gitswarm/etc/gitlab alone
      content.gsub!(%r{(?<!gitswarm)/etc/gitlab}, '/etc/gitswarm')

      # rename gitlab.rb to gitswarm.rb but be selective to avoid mucking non /etc/ versions
      # also get gitlab-secrets.json
      content.gsub!(%r{(etc|gitswarm)/gitlab.rb}, '\1/gitswarm.rb')
      content.gsub!(%r{/etc/gitswarm/gitlab\-secrets\.json}, '/etc/gitswarm/gitswarm-secrets.json')

      # rename /opt/gitlab and /var/opt/gitlab
      content.gsub!('/opt/gitlab', '/opt/gitswarm')

      # handle log path
      content.gsub!(%r{/var/log/gitlab}, '/var/log/gitswarm')

      # Rename calls to the gitlab- bin scripts
      # we're careful to avoid replacing /opt/gitlab/embedded/services/gitlab-rails
      content.gsub!(%r{/bin/gitlab\-(ctl|rake|rails)}, '/bin/gitswarm-\1')
      content.gsub!(%r{(?<!/)gitlab\-(ctl|rake|rails)}, 'gitswarm-\1')

      # rename the various rake tasks e.g. rake gitlab:check to rake gitswarm:check
      content.gsub!(/(gitswarm-)?rake(\s+)gitlab:/, '\1rake\2gitswarm:')
      content.gsub!(/gitlab:(env|gitlab_shell|sidekiq|app):/, 'gitswarm:\1:')
      content.gsub!(/gitlab:check /, 'gitswarm:check ')

      # deal with references to the omnibus package
      content.gsub!(/Omnibus GitSwarm/i, 'GitSwarm')
      content.gsub!(/Omnibus-gitlab /, 'GitSwarm ')
      # Commenting out line till a rubocop fix is made: content.gsub!(/(omnibus)-gitlab(?!\/)/i, 'gitswarm')
      content.gsub!(/Omnibus Installation/, 'Package Installation')
      content.gsub!(/Omnibus-packages/, 'GitSwarm packages')

      # do a variety of page specific touch-ups

      content.gsub!(/To see a more in-depth overview see the.*$/, '') if file == 'structure'

      # the markdown page needs some finesse to avoid taking undue credit
      if file == 'markdown'
        content.gsub!('For GitSwarm we developed something we call', 'GitLab developed something called')
        content.gsub!('Here\'s our logo', 'Here\'s GitLab\'s logo')
      end

      # this section is just for EE users; nuke it
      if category == 'workflow' && file == 'groups'
        content.gsub!(/## Managing group memberships via LDAP.*?(?!##)/m, '')
      end

      # unfair to steal their voice on this bit; put it back
      content.gsub!('At GitSwarm we are guilty', 'At GitLab we are guilty') if file == 'gitlab_flow'

      # a few lines that refer to GitLab versions that pre-date our usage
      if file == 'ldap'
        content.gsub!(/Please note that before version.*$/, '')
        content.gsub!(/The old LDAP integration syntax still works in GitSwarm.*$/, '')
        content.gsub!(/^.*contains LDAP settings in both the old syntax and the new syntax.*$/, '')
      end

      # this is a link to GitLab flow and should stay GitLab
      content.gsub!('[GitSwarm]', '[GitLab]') if file == 'omniauth'

      if file == 'custom_hooks'
        content.gsub!('As of gitlab-shell version 2.2.0 (which requires GitSwarm 7.5+), GitSwarm', '')
        content.gsub!('administrators can add custom git hooks to any GitSwarm project.', '')
      end

      # the cleanup page only applies to old versions; nuke the link from the index page
      content.gsub!(/^.*Cleaning up Redis sessions.*$/, '') if category == 'operations' && file == 'README'

      content.gsub!('![backup banner](backup_hrz.png)', '')

      content.gsub!('GitSwarm support', 'GitLab support') if file == 'import_projects_from_gitlab_com'

      # remove a link to GitLab on the web_hooks page
      if category == 'web_hooks' && file == 'web_hooks'
        content.gsub!(/\[the certificate will not be verified\]\([^)]+\)/, 'the certificate will not be verified')
      end

      # we do not accept contributions, so remove "contribute" section
      if file == 'migrating_from_svn'
        content.gsub!('Contribute to this guide', '')
        content.gsub!(/^We welcome all.+control systems\.$/, '')
      end

      # apply a note about using SSH instead of HTTP(S), to avoid
      # resource issues.
      if category == 'workflow' && file == 'workflow'
        content += <<EOS

Note: For performance reasons, it is better to clone from a repo via SSH
instead of HTTP(S). GitSwarm maintains a limited pool of web worker
processes, and each HTTP(S) push/pull/fetch operation ties up a worker
process until completion.
EOS
      end

      # return the munged string
      content
    end
  end
end

class HelpController
  prepend PerforceSwarm::HelpControllerExtension
  skip_before_filter :authenticate_user!,
                     :reject_blocked
end
