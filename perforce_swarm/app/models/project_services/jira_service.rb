require Rails.root.join('app', 'models', 'project_services', 'jira_service')

module PerforceSwarm
  module JiraServiceExtension
    def help
      # remove the last line; it talks about gitlab-ee which doesn't apply
      super.sub(/\n[^\n]+$/, '')
    end
  end
end

class JiraService < IssueTrackerService
  prepend PerforceSwarm::JiraServiceExtension
end
