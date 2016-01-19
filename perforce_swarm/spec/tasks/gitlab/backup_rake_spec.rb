require 'spec_helper'
require 'rake'

describe 'gitlab:app namespace rake task' do
  before :all do
    Rake.application.rake_require 'tasks/gitlab/task_helpers'
    Rake.application.rake_require 'tasks/gitlab/backup'
    Rake.application.rake_require 'tasks/gitlab/shell'
    # empty task as env is already loaded
    Rake::Task.define_task :environment
  end

  def run_rake_task(task_name)
    Rake::Task[task_name].reenable
    Rake.application.invoke_task task_name
  end

  def reenable_backup_sub_tasks
    folder_list = %w(db repo uploads builds artifacts lfs)
    folder_list += %w(pages) if PerforceSwarm.ee?
    folder_list.each do |subtask|
      Rake::Task["gitlab:backup:#{subtask}:create"].reenable
    end
  end

  describe 'backup_restore' do
    before do
      # avoid writing task output to spec progress
      allow($stdout).to receive :write
    end

    context 'gitlab version' do
      before do
        allow(Dir).to receive(:glob).and_return([])
        allow(Dir).to receive(:chdir)
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:exist?).and_return(true)
        allow(Kernel).to receive(:system).and_return(true)
        allow(FileUtils).to receive(:cp_r).and_return(true)
        allow(FileUtils).to receive(:mv).and_return(true)
        allow(Rake::Task['gitlab:shell:setup']).to receive(:invoke).and_return(true)
      end

      let(:gitswarm_version) { PerforceSwarm::VERSION }

      it 'should fail on mismatch', override: true do
        allow(YAML).to receive(:load_file).and_return(gitswarm_version: "not #{gitswarm_version}")
        expect { run_rake_task('gitlab:backup:restore') }.to(
          raise_error SystemExit
        )
      end

      it 'should invoke restoration on match', override: true do
        allow(YAML).to receive(:load_file).and_return(gitswarm_version: gitswarm_version)
        expect(Rake::Task['gitlab:backup:db:restore']).to receive(:invoke)
        expect(Rake::Task['gitlab:backup:repo:restore']).to receive(:invoke)
        expect(Rake::Task['gitlab:backup:builds:restore']).to receive(:invoke)
        expect(Rake::Task['gitlab:backup:uploads:restore']).to receive(:invoke)
        expect(Rake::Task['gitlab:backup:artifacts:restore']).to receive(:invoke)
        expect(Rake::Task['gitlab:backup:pages:restore']).to receive(:invoke) if PerforceSwarm.ee?
        expect(Rake::Task['gitlab:backup:lfs:restore']).to receive(:invoke)
        expect(Rake::Task['gitlab:shell:setup']).to receive(:invoke)
        expect { run_rake_task('gitlab:backup:restore') }.not_to raise_error
      end
    end
  end # backup_restore task

  describe 'backup_create' do
    def tars_glob
      Dir.glob(File.join(Gitlab.config.backup.path, '*_gitswarm_backup.tar'))
    end

    def create_backup
      FileUtils.rm tars_glob

      # Redirect STDOUT and run the rake task
      orig_stdout = $stdout
      $stdout = StringIO.new
      reenable_backup_sub_tasks
      run_rake_task('gitlab:backup:create')
      reenable_backup_sub_tasks
      $stdout = orig_stdout

      @backup_tar = tars_glob.first
    end

    before do
      create_backup
    end

    after do
      FileUtils.rm(@backup_tar)
    end

    context 'archive file permissions' do
      it 'should set correct permissions on the tar file', override: true do
        expect(File.exist?(@backup_tar)).to be_truthy
        expect(File::Stat.new(@backup_tar).mode.to_s(8)).to eq('100600')
      end

      context 'with custom archive_permissions' do
        before do
          allow(Gitlab.config.backup).to receive(:archive_permissions).and_return(0651)
          # We created a backup in a before(:all) so it got the default permissions.
          # We now need to do some work to create a _new_ backup file using our stub.
          FileUtils.rm(@backup_tar)
          create_backup
        end

        it 'uses the custom permissions', override: true do
          expect(File::Stat.new(@backup_tar).mode.to_s(8)).to eq('100651')
        end
      end
    end

    it 'should set correct permissions on the tar contents', override: true do
      archive_files =
        %W(tar -tvf #{@backup_tar} db uploads.tar.gz repositories builds.tar.gz artifacts.tar.gz lfs.tar.gz)
      archive_files += %w(pages.tar.gz) if PerforceSwarm.ee?
      tar_contents, exit_status = Gitlab::Popen.popen(archive_files)
      expect(exit_status).to eq(0)
      expect(tar_contents).to match('db/')
      expect(tar_contents).to match('uploads.tar.gz')
      expect(tar_contents).to match('repositories/')
      expect(tar_contents).to match('builds.tar.gz')
      expect(tar_contents).to match('artifacts.tar.gz')
      expect(tar_contents).to match('pages.tar.gz') if PerforceSwarm.ee?
      expect(tar_contents).to match('lfs.tar.gz')

      if PerforceSwarm.ee?
        content_regex =
          %r{^.{4,9}[rwx].* (database.sql.gz|uploads.tar.gz|repositories|builds.tar.gz|pages.tar.gz|artifacts.tar.gz)/$}
      else
        content_regex =
          %r{^.{4,9}[rwx].* (database.sql.gz|uploads.tar.gz|repositories|builds.tar.gz|artifacts.tar.gz)/$}
      end
      expect(tar_contents).not_to match(content_regex)
    end

    it 'should delete temp directories', override: true do
      if PerforceSwarm.ee?
        dirs = '{db,repositories,uploads,builds,artifacts,pages,lfs}'
      else
        dirs = '{db,repositories,uploads,builds,artifacts,lfs}'
      end
      temp_dirs = Dir.glob(File.join(Gitlab.config.backup.path, dirs))

      expect(temp_dirs).to be_empty
    end
  end # backup_create task

  describe 'Skipping items' do
    def tars_glob
      Dir.glob(File.join(Gitlab.config.backup.path, '*_gitswarm_backup.tar'))
    end

    before :all do
      @origin_cd = Dir.pwd

      reenable_backup_sub_tasks

      FileUtils.rm tars_glob

      # Redirect STDOUT and run the rake task
      orig_stdout = $stdout
      $stdout = StringIO.new
      ENV['SKIP'] = 'repositories,uploads'
      run_rake_task('gitlab:backup:create')
      $stdout = orig_stdout

      @backup_tar = tars_glob.first
    end

    after :all do
      FileUtils.rm(@backup_tar)
      Dir.chdir @origin_cd
    end

    it 'does not contain skipped item', override: true do
      archive_files =
        %W(tar -tvf #{@backup_tar} db uploads.tar.gz repositories builds.tar.gz artifacts.tar.gz lfs.tar.gz)
      archive_files += %w(pages.tar.gz) if PerforceSwarm.ee?
      tar_contents, _exit_status = Gitlab::Popen.popen(archive_files)

      expect(tar_contents).to match('db/')
      expect(tar_contents).to match('uploads.tar.gz')
      expect(tar_contents).to match('builds.tar.gz')
      expect(tar_contents).to match('artifacts.tar.gz')
      expect(tar_contents).to match('pages.tar.gz') if PerforceSwarm.ee?
      expect(tar_contents).to match('lfs.tar.gz')
      expect(tar_contents).not_to match('repositories/')
    end

    it 'does not invoke repositories restore', override: true do
      allow(Rake::Task['gitlab:shell:setup']).to receive(:invoke).and_return(true)
      allow($stdout).to receive :write

      expect(Rake::Task['gitlab:backup:db:restore']).to receive :invoke
      expect(Rake::Task['gitlab:backup:repo:restore']).not_to receive :invoke
      expect(Rake::Task['gitlab:backup:uploads:restore']).not_to receive :invoke
      expect(Rake::Task['gitlab:backup:builds:restore']).to receive :invoke
      expect(Rake::Task['gitlab:backup:artifacts:restore']).to receive :invoke
      expect(Rake::Task['gitlab:backup:pages:restore']).to receive :invoke if PerforceSwarm.ee?
      expect(Rake::Task['gitlab:backup:lfs:restore']).to receive :invoke
      expect(Rake::Task['gitlab:shell:setup']).to receive :invoke
      expect { run_rake_task('gitlab:backup:restore') }.not_to raise_error
    end
  end
end # gitlab:app namespace
