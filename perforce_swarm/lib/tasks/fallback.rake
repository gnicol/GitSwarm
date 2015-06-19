# This rule will capture any calls to the gitswarm namespace that don't already have defined tasks
rule (/^gitswarm:/), [:args] do |task, args|
  task_name  = task.name.sub(/^gitswarm:/, 'gitlab:').sub(/gitlab_/, 'gitswarm_')

  if Rake.application.lookup(task_name)
    Rake.application[task_name].invoke(args[:args])
  else
    fail "Don't know how to build task '#{task.name}'"
  end
end

module PerforceSwarm
  module RakeTaskExtension
    # replace namespace name when displaying and searching rake tasks
    def name
      super.sub(/^gitlab:/, 'gitswarm:').sub(/gitlab_/, 'gitswarm_')
    end

    # replace GitLab text in rake comments
    def transform_comments(separator, &block)
      comment = super
      comment = comment.sub('GITLAB', 'GITSWARM').sub('gitlab', 'gitswarm').sub(/GitLab/, 'GitSwarm') if comment
      comment
    end
  end
end

class Rake::Task
  prepend PerforceSwarm::RakeTaskExtension
end
