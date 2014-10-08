namespace :pspec do
  @rspec_command = "rspec perforce_swarm/spec spec"

  desc 'GITLAB | Run request specs'
  task :api do
    cmds = [
      %W(rake gitlab:setup),
      %W(#{@rspec_command} --tag @api)
    ]
    run_commands(cmds)
  end

  desc 'GITLAB | Run feature specs'
  task :feature do
    cmds = [
      %W(rake gitlab:setup),
      %W(#{@rspec_command} --tag @feature)
    ]
    run_commands(cmds)
  end

  desc 'GITLAB | Run other specs'
  task :other do
    cmds = [
      %W(rake gitlab:setup),
      %W(#{@rspec_command} --tag ~@api --tag ~@feature)
    ]
    run_commands(cmds)
  end
end

desc "GITLAB | Run specs"
task :pspec do
  cmds = [
    %W(rake gitlab:setup),
    %W(#{@rspec_command}),
  ]
  run_commands(cmds)
end

def run_commands(cmds)
  cmds.each do |cmd|
    system({'RAILS_ENV' => 'test', 'force' => 'yes'}, *cmd) or raise("#{cmd} failed!")
  end
end
