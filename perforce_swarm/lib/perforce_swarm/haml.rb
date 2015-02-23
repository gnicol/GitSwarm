module PerforceSwarm
  module HamlParserExtension
    GITSWARM_REPLACE_REGEX = /GitLab(?!(\.com|\s+[Ff]lavored [Mm]arkdown|\$))/
    def parse_tag(line)
      super translate(line)
    end

    def plain(text, escape_html = nil)
      super translate(text), escape_html
    end

    def translate(text)
      # ensure that instances of $GitLab$ are escaped from the translation, and get replaced with GitLab
      text.gsub(GITSWARM_REPLACE_REGEX, 'GitSwarm').gsub(/\$GitLab\$/, 'GitLab')
    end
  end
end

require 'haml'
class Haml::Parser
  prepend PerforceSwarm::HamlParserExtension
end
