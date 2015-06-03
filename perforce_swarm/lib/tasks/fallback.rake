# This rule will capture any calls to the gitswarm namespace that don't already have defined tasks
rule(/^gitswarm:/) do |task|
  task_name  = task.name.sub(/^gitswarm:/, 'gitlab:')

  if Rake.application.lookup(task_name)
    Rake.application[task_name].invoke
  else
    fail "Don't know how to build task '#{task.name}'"
  end
end

module PerforceSwarm
  module RakeTaskExtension
    # replace namespace name when displaying and searching rake tasks
    def name
      super.sub(/^gitlab:/, 'gitswarm:')
    end

    # replace GitLab text in rake comments
    def transform_comments(separator, &block)
      comment = super
      comment = comment.sub('GITLAB', 'GITSWARM').sub('gitlab', 'gitswarm').sub(/GitLab/i, 'GitSwarm') if comment
      comment
    end
  end
end

class Rake::Task
  prepend PerforceSwarm::RakeTaskExtension
end
