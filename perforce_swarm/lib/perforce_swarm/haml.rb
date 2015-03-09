module PerforceSwarm
  module HamlParserExtension
    def parse_tag(line)
      super PerforceSwarm::Branding.rebrand(line)
    end

    def plain(text, escape_html = nil)
      super PerforceSwarm::Branding.rebrand(text), escape_html
    end
  end
end

require 'haml'
class Haml::Parser
  prepend PerforceSwarm::HamlParserExtension
end
