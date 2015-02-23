module PerforceSwarm
  module HamlParserExtension
    REPLACE_REGEX = /GitLab(?!\.com|\s+[Ff]lavored [Mm]arkdown)/
    def parse_tag(line)
      super line.gsub(REPLACE_REGEX, 'GitSwarm')
    end

    def plain(text, escape_html = nil)
      super text.gsub(REPLACE_REGEX, 'GitSwarm'), escape_html
    end
  end
end

require 'haml'
class Haml::Parser
  prepend PerforceSwarm::HamlParserExtension
end
