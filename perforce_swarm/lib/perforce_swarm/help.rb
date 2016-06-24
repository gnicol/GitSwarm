require 'English'

module PerforceSwarm
  module Help
    def self.render(&block)
      # determine all of the paths we'll scan for doc files
      # note the last listed path wins if a file appears in multiple locations
      stock_dir = Rails.root.join('doc')
      dirs  = [stock_dir, Rails.root.join('perforce_swarm', 'doc-ce')]
      dirs += [Rails.root.join('perforce_swarm', 'doc-ee')] if PerforceSwarm.ee?

      dirs.each do |dir|
        Dir.glob(File.join(dir, '**/*')) do |file|
          next if File.directory?(file)

          content = File.read(file)
          file.slice!(dir.to_s)
          if dir == stock_dir && file =~ %r{([^/]+)/(.+)\.md$}
            content = preprocess($LAST_MATCH_INFO[1], $LAST_MATCH_INFO[2])
          end

          # provide the preprocessed content and the category/file path
          block.call(content, file)
        end
      end
    end

    def self.preprocess(category, file)
      content = File.read(Rails.root.join('doc', category, "#{file}.md"))

      # map GitLab version declarations to GitSwarm versions
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)9\.[x0-9](\.\d+)?/, 'GitSwarm 2016.3')
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)8\.[5678](\.\d+)?/, 'GitSwarm 2016.2')
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)8\.[1234](\.\d+)?/, 'GitSwarm 2016.1')
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)8\.0(\.\d+)?/, 'GitSwarm 2015.4')
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)7\.13(\.\d+)?/, 'GitSwarm 2015.3')
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)7\.12(\.\d+)?/, 'GitSwarm 2015.2')
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)7\.11(\.\d+)?/, 'GitSwarm 2015.2')
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)7\.10(\.\d+)?/, 'GitSwarm 2015.2')
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)7\.[.2-9]*\d/, 'GitSwarm 2015.2')
      content.gsub!(/(GitLab(( |\n\s*)EE)?|Edition)( |\n\s*)[1-6](\.[x0-9](\.\d+)?)?/, 'GitSwarm 2015.2')
      content.gsub!(/\[introduced\]\[(c|e)e-\d+\]/, 'introduced')

      # replace GitLab attribution with our own
      content.gsub!(/GitLab B\.V\./, 'Perforce Software')

      if PerforceSwarm.ee?
        content.gsub!(/about (your )?GitLab/, 'about \1GitSwarm EE')
        content.gsub!('Check GitLab configuration', 'Check GitSwarm EE configuration')
      else
        content.gsub!(/about (your )?GitLab/, 'about \1GitSwarm')
        content.gsub!('Check GitLab configuration', 'Check GitSwarm configuration')
      end

      content.gsub!('look at our ', 'look at GitLab\'s ')

      # hit GitLab occurrences that look ok to update
      content = PerforceSwarm::Branding.rebrand(content)

      # try to clarify its not our website
      content.gsub!(/our website/i, "GitLab's website")

      # redirect external help links to our site
      content.gsub!(%r{http://docs?.gitlab.com/ce/}, 'https://www.perforce.com/perforce/doc.current/manuals/gitswarm/')
      content.gsub!(%r{http://docs?.gitlab.com/ee/}, 'https://www.perforce.com/perforce/doc.current/manuals/gitswarm-ee/')

      # fix example links value
      content.gsub!(/(your-)?gitlab\.example\.com/, '\1gitswarm.example.com')
      content.gsub!(/gitlab\.company\.com/, 'gitswarm.company.com')

      # replace /etc/gitlab with /etc/gitswarm but leave /opt/gitswarm/etc/gitlab alone
      content.gsub!(%r{(?<!gitswarm)/etc/gitlab}, '/etc/gitswarm')

      # rename gitlab.rb to gitswarm.rb but be selective to avoid mucking non /etc/ versions
      # also get gitlab-secrets.json
      content.gsub!(%r{(etc|gitswarm)/gitlab.rb}, '\1/gitswarm.rb')
      content.gsub!(%r{/etc/gitswarm/gitlab\-secrets\.json}, '/etc/gitswarm/gitswarm-secrets.json')
      content.gsub!('`gitlab.rb`', '`/etc/gitswarm/gitswarm.rb`')

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
      if PerforceSwarm.ee?
        content.gsub!(/Omnibus GitSwarm/i, 'GitSwarm EE')
        content.gsub!(/Omnibus-gitlab /, 'GitSwarm EE')
        content.gsub!(/Omnibus-packages/, 'GitSwarm EE packages')
      else
        content.gsub!(/Omnibus GitSwarm/i, 'GitSwarm')
        content.gsub!(/Omnibus-gitlab /, 'GitSwarm ')
        content.gsub!(/Omnibus-packages/, 'GitSwarm packages')
      end
      content.gsub!(/# omnibus-gitlab/, '# package installations')
      content.gsub!(%r{(omnibus)-gitlab(?!/)}i, 'gitswarm')

      content.gsub!('(Omnibus)', '(package installation)')
      content.gsub!('(Omnibus-only)', '(package installations only)')
      content.gsub!("by omnibus\nwith", "by the package installation\nwith")
      content.gsub!('Configure using Omnibus', 'Configure the package installation')
      content.gsub!('Consider the Omnibus package installation', 'Consider the package installation')
      content.gsub!('If using Omnibus', 'If using the package installation')
      content.gsub!('in Omnibus,', 'in package installations,')
      content.gsub!('Omnibus allows', 'Package installations allow')
      content.gsub!('The omnibus design', 'The design of the package installation')
      content.gsub!(/Omnibus(\n| )configuration/i, 'package installation configuration')
      content.gsub!('Omnibus documentation', 'package installation documentation')
      content.gsub!('Omnibus Installation', 'Package Installation')
      content.gsub!(/Omnibus(\n| )installation/i, 'package\1installation')
      content.gsub!(/omnibus installs/i, 'package installations')
      content.gsub!(/(^|>)# Omnibus( install)?$/, '\1# Package installations')
      content.gsub!(/# Omnibus package( installation)?/, '# Package installation')
      content.gsub!('Omnibus Package', 'Package Installation')
      content.gsub!(/Omnibus(\n| )package/i, 'package\1installation')
      content.gsub!('omnibus version', 'package installation')
      content.gsub!('The omnibus reconfigure', "The package installation's reconfigure")
      content.gsub!('Updating Omnibus from', 'Updating the package installation from')
      content.gsub!("without using\nOmnibus", "without using\nthe package installation")
      content.gsub!('Omnibus Trusted Chain', PerforceSwarm.short_name + ' Trusted Chain')
      content.gsub!('Omnibus 7.14', PerforceSwarm.short_name + ' 2016.1')
      content.gsub!('GitSwarm Omnibus', 'GitSwarm package installation')
      content.gsub!('GitSwarm EE Omnibus', 'GitSwarm EE package installation')

      # say 'source installations' consistently
      content.gsub!('# Installations from source', '# Source installations')
      content.gsub!(/installations(\n| )from( the)? source/, 'source\1installations')
      content.gsub!(/Installation from( the)? source/, 'Source installation')
      content.gsub!(/installation from( the)? source/, 'source installation')
      content.gsub!(/manual install(ation)?s/, 'source install\1s')
      content.gsub!(/(^|>)# Source$/, '\1# Source installations')

      # fix incoming email addresses
      content.gsub!('gitlab-incoming', 'gitswarm-incoming')

      # fixup reference links that include the label GitLab
      content.gsub!(/\[(restart|reconfigure) gitlab\]/, '[\1 ' + PerforceSwarm.short_name + ']')

      # fix escaped <> so that Pandoc's Markdown can display them correctly
      content.gsub!('\<', '&lt;')
      content.gsub!('\>', '&gt;')

      # do a variety of page specific touch-ups

      content.gsub!(/To see a more in-depth overview see the.*$/, '') if file == 'structure'

      # the markdown page needs some finesse to avoid taking undue credit
      if file == 'markdown'
        content.gsub!('For GitSwarm we developed something we call', 'GitLab developed something called')
        content.gsub!('Here\'s our logo', 'Here\'s GitLab\'s logo')
      end

      # this section is just for EE users; nuke it
      if category == 'workflow' && file == 'groups' && PerforceSwarm.ce?
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

      # Drop the gitlab.com specific line
      if file == 'unicorn'
        content.gsub!(/^.*stands out in the log snippet above.*$/, '')
        content.gsub!(/^.*'worker 4' was serving requests for only 23 seconds.*$/, '')
        content.gsub!(/^.*a normal value for our current GitLab\.com.*$/, '')
      end

      # mention the gitswarm user instead of gitlab in the jira integration (in EE docs)
      content.gsub!('`gitlab`', '`gitswarm`') if file == 'jira'

      # apply a note about using SSH instead of HTTP(S), to avoid
      # resource issues.
      if category == 'workflow' && file == 'workflow'
        content += if PerforceSwarm.ee?
                     <<EOS

Note: For performance reasons, it is better to clone from a repo via SSH
instead of HTTP(S). GitSwarm EE maintains a limited pool of web worker
processes, and each HTTP(S) push/pull/fetch operation ties up a worker
process until completion.
EOS
                   else
                     <<EOS

Note: For performance reasons, it is better to clone from a repo via SSH
instead of HTTP(S). GitSwarm maintains a limited pool of web worker
processes, and each HTTP(S) push/pull/fetch operation ties up a worker
process until completion.
EOS
                   end
      end

      # point the archived download link to our ftp.
      if file == 'backup_restore'
        # ee isn't on the ftp; just turn the link to plain text
        if PerforceSwarm.ee?
          content.gsub!(/\[required version\]\([^\)]+\)/, 'required version')
        end

        content.gsub!('https://www.gitlab.com/downloads/archives/', 'http://ftp.perforce.com/perforce')
      end

      # return the munged string
      content
    end
  end
end
