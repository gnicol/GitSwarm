module PerforceSwarm
  module Branding
    REPLACE_REGEX = /
        GitLab(?!\.com
        |\s+[0-9]
        |\s+CI
        |\s+[Ff]lavored [Mm]arkdown
        |\s+[Ff]low
        |\s+Inc
        |\s+[Mm]ail[Rr]oom
        |\s+[Rr]unner
        |\s+Shell
        |\s+[Ss]idekiq
        |\s+[Uu]nicorn
        |\s+[Ww]orkflow
        |\s+[Ww]orkhorse
        |\$)
    /x

    def self.rebrand(text)
      # replace safe looking instances of GitLab with GitSwarm (skipping .com, Flavored Markdown, Literal instances)
      # ensure that instances of $GitLab$ get replaced with literal word GitLab
      # ensure GitLab B.V. (post processing GitSwarm B.V.) turns into Perforce Software
      # ensure _gitlab_backup.tar gets replaced with _gitswarm_backup.tar (for help files)
      text.gsub(REPLACE_REGEX, 'GitSwarm')
          .gsub('$GitLab$', 'GitLab')
          .gsub('GitSwarm B.V.', 'Perforce Software')
          .gsub('_gitlab_backup.tar', '_gitswarm_backup.tar')
    end
  end
end
