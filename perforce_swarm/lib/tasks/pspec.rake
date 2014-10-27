namespace :pspec do
  @rspec_command = 'rspec spec perforce_swarm/spec'

  desc 'GITLAB | Run request specs'
  task :api do
    cmds = [
      %w(rake gitlab:setup),
      %W(#{@rspec_command} --tag @api)
    ]
    run_commands(cmds)
  end

  desc 'GITLAB | Run feature specs'
  task :feature do
    cmds = [
      %w(rake gitlab:setup),
      %W(#{@rspec_command} --tag @feature)
    ]
    run_commands(cmds)
  end

  desc 'GITLAB | Run other specs'
  task :other do
    cmds = [
      %w(rake gitlab:setup),
      %W(#{@rspec_command} --tag ~@api --tag ~@feature)
    ]
    run_commands(cmds)
  end
end

desc 'GITLAB | Run specs'
task :pspec do
  arglist = ENV.select { |k, _v| (%w(line example tag pattern format out backtrace color profile warnings P e l t f o b c p w).include?(k)) }
               .map { |k, v| (k.length > 1 ? '--' :  '-') + "#{k} #{v}" }.join(' ')

  cmds = [
    %w(rake gitlab:setup),
    "#{@rspec_command} #{arglist}".split("\s")
  ]
  run_commands(cmds)
end

def run_commands(cmds)
  cmds.each do |cmd|
    system({ 'RAILS_ENV' => 'test', 'force' => 'yes' }, *cmd) || fail("#{cmd} failed!")
  end
end
