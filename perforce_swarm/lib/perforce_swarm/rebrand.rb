module PerforceSwarm
  module Branding
    REPLACE_REGEX = /GitLab(?!\.com|\s+[Ff]lavored [Mm]arkdown| [Ff]low| [Ww]orkflow| CI| [Rr]unner| Shell|\$)/

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
