module PerforceSwarm
  module Branding
    GITSWARM_REPLACE_REGEX = /GitLab(?!\.com|\s+[Ff]lavored [Mm]arkdown| [Ff]low| [Ww]orkflow| CI| Shell|\$)/

    def self.rebrand(text)
      # replace safe looking instances of GitLab with GitSwarm (skipping .com, Flavored Markdown, Literal instances)
      # ensure that instances of $GitLab$ get replaced with literal word GitLab
      # ensure GitLab B.V. (post processing GitSwarm B.V.) turns into Perforce Software
      text.gsub(GITSWARM_REPLACE_REGEX, 'GitSwarm')
        .gsub('$GitLab$', 'GitLab')
        .gsub('GitSwarm B.V.', 'Perforce Software')
    end
  end
end
