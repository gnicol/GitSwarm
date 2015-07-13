require Rails.root.join('lib', 'backup', 'manager')

module PerforceSwarm
  module BackupManagerExtension
    def pack
      # saving additional informations
      s = {}
      s[:db_version]         = "#{ActiveRecord::Migrator.current_version}"
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

        FileUtils.chmod(0700, folders_to_backup)

        # create archive
        $progress.print "Creating backup archive: #{tar_file} ... "
        orig_umask = File.umask(0077)
        if Kernel.system('tar', '-cf', tar_file, *backup_contents)
          $progress.puts 'done'.green
        else
          puts "creating archive #{tar_file} failed".red
          abort 'Backup failed'
        end
        File.umask(orig_umask)

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
      file_list = Dir.glob('*_gitswarm_backup.tar').each.map { |f| f.split(/_/).first.to_i }
      puts 'no backups found' if file_list.count == 0

      if file_list.count > 1 && ENV['BACKUP'].nil?
        puts 'Found more than one backup, please specify which one you want to restore:'
        puts 'rake gitswarm:backup:restore BACKUP=timestamp_of_backup'
        exit 1
      end

      if ENV['BACKUP'].nil?
        tar_file = File.join("#{file_list.first}_gitswarm_backup.tar")
      else
        tar_file = File.join(ENV['BACKUP'] + '_gitswarm_backup.tar')
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

      ENV['VERSION'] = "#{settings[:db_version]}" if settings[:db_version].to_i > 0

      # restoring mismatching backups can lead to unexpected problems
      if settings[:gitswarm_version] != PerforceSwarm::VERSION
        puts 'GitSwarm version mismatch:'.red
        puts "  Your current GitSwarm version (#{PerforceSwarm::VERSION}) differs"\
             ' from the GitSwarm version in the backup!'.red
        puts '  Please switch to the following version and try again:'.red
        puts "  version: #{settings[:gitswarm_version]}".red
        exit 1
      end
    end
  end
end

class Backup::Manager
  prepend PerforceSwarm::BackupManagerExtension
end
