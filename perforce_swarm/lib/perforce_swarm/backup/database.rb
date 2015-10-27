require Rails.root.join('lib', 'backup', 'database')

module PerforceSwarm
  module BackupDatabaseExtension
    def restore
      super
      $progress.puts 'Running migrations ... '
      Rake::Task['db:migrate'].invoke
    end
  end
end

class Backup::Database
  prepend PerforceSwarm::BackupDatabaseExtension
end
