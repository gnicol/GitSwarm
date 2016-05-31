require Rails.root.join('lib', 'backup', 'manager')

module PerforceSwarm
  module BackupManagerExtension
    def pack
      # saving additional informations
      s = {}
      s[:db_version]         = ActiveRecord::Migrator.current_version.to_s
      s[:backup_created_at]  = Time.now
      s[:gitswarm_version]   = PerforceSwarm::VERSION
      s[:tar_version]        = tar_version
      s[:skipped]            = ENV['SKIP']
      tar_file = "#{s[:backup_created_at].to_i}_gitswarm_backup.tar"

      Dir.chdir(Gitlab.config.backup.path) do
        File.open("#{Gitlab.config.backup.path}/backup_information.yml",
                  'w+') do |file|
          file << s.to_yaml.gsub(/^---\n/, '')
        end

        # create archive
        $progress.print "Creating backup archive: #{tar_file} ... "
        # Set file permissions on open to prevent chmod races.
        tar_system_options = { out: [tar_file, 'w', Gitlab.config.backup.archive_permissions] }
        if Kernel.system('tar', '-cf', '-', *backup_contents, tar_system_options)
          $progress.puts 'done'.green
        else
          puts "creating archive #{tar_file} failed".red
          abort 'Backup failed'
        end

        upload(tar_file)
      end
    end

    def remove_old
      # delete backups
      $progress.print 'Deleting old backups ... '
      keep_time = Gitlab.config.backup.keep_time.to_i

      if keep_time > 0
        removed = 0

        Dir.chdir(Gitlab.config.backup.path) do
          file_list = Dir.glob('*_gitswarm_backup.tar')
          file_list.map! { |f| Regexp.last_match(1).to_i if f =~ /(\d+)_gitswarm_backup.tar/ }
          file_list.sort.each do |timestamp|
            next unless Time.at(timestamp) < (Time.now - keep_time)
            next unless Kernel.system(*%W(rm #{timestamp}_gitswarm_backup.tar))
            removed += 1
          end
        end

        $progress.puts "done. (#{removed} removed)".green
      else
        $progress.puts 'skipping'.yellow
      end
    end

    def unpack
      Dir.chdir(Gitlab.config.backup.path)
      # check for existing backups in the backup dir
      file_list = Dir.glob('*_git{swarm,lab}_backup.tar')
      puts 'no backups found' if file_list.empty?

      if file_list.count > 1 && ENV['BACKUP'].nil?
        puts 'Found more than one backup, please specify which one you want to restore:'
        puts 'rake gitswarm:backup:restore BACKUP=timestamp_of_backup'
        exit 1
      end

      if ENV['BACKUP'].nil?
        tar_file = file_list.first
      else
        tar_file = File.join(ENV['BACKUP'] + '_gitswarm_backup.tar')
        tar_file = File.join(ENV['BACKUP'] + '_gitlab_backup.tar') unless File.exist?(tar_file)
      end

      unless File.exist?(tar_file)
        puts "The specified backup doesn't exist!"
        exit 1
      end

      $progress.print 'Unpacking backup ... '

      if Kernel.system(*%W(tar -xf #{tar_file}))
        $progress.puts 'done'.green
      else
        puts 'unpacking backup failed'.red
        exit 1
      end

      ENV['VERSION'] = settings[:db_version].to_s if settings[:db_version].to_i > 0

      # check for neither gitlab nor gitswarm version
      unless settings[:gitlab_version] || settings[:gitswarm_version]
        puts 'This does not appear to be a valid GitSwarm or GitLab backup file.'.red
        puts ' We could not find a :gitlab_version nor a :gitswarm_version in backup_information.yml.'.red
        exit 1
      end

      # restoring mismatching backups can lead to unexpected problems
      if settings[:gitswarm_version] && settings[:gitswarm_version] != PerforceSwarm::VERSION
        puts 'GitSwarm version mismatch:'.red
        puts "  Your current GitSwarm version (#{PerforceSwarm::VERSION}) differs"\
             ' from the GitSwarm version in the backup!'.red
        puts '  Please switch to the following version and try again:'.red
        puts "  version: #{settings[:gitswarm_version]}".red
        exit 1
      end

      # no gitswarm version, but see if we have a compatible gitlab version
      if settings[:gitlab_version] && settings[:gitlab_version] != Gitlab::VERSION
        puts 'GitSwarm version mismatch:'.red
        puts "  Your current GitSwarm version (#{PerforceSwarm::VERSION}) is based on"\
             " GitLab (#{Gitlab::VERSION}) which differs from the GitLab version in the backup!".red
        puts '  Please switch to a GitSwarm version based on GitLab:'.red
        puts "  #{settings[:gitlab_version]} and try again.".red
        exit 1
      end
    end
  end
end

class Backup::Manager
  prepend PerforceSwarm::BackupManagerExtension
end
