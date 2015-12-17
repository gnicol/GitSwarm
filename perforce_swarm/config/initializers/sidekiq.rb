Sidekiq.configure_server do
  # Sidekiq-cron: load recurring jobs from schedule.yml
  schedule_file = 'perforce_swarm/config/schedule.yml'
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end

  # randomize when the worker runs to be on a random minute of every day
  Sidekiq::Cron::Job.create(
    name: 'verion_cache_worker',
    cron: "#{rand(60)} #{rand(24)} * * *",
    class: 'PerforceSwarm::VersionCacheWorker'
  )
end
