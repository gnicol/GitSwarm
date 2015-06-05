module PerforceSwarm
  module PageLayoutHelper
    def page_title(*titles)
      super(*titles).gsub!(/GitLab/, 'GitSwarm')
    end
  end
end

require Rails.root.join('app', 'helpers', 'page_layout_helper')
module PageLayoutHelper
  prepend PerforceSwarm::PageLayoutHelper
end