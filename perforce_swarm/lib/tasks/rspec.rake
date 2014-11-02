namespace :rspec do
  @engine_command = 'rspec perforce_swarm/spec'
  @rspec_command = 'rspec spec perforce_swarm/spec'
  @rspec_w_overrides_command = 'rspec -t override -t main_app spec perforce_swarm/spec'

  desc 'GITLAB | Run main application specs with engine overrides'
  task :app_and_over do
    arglist = ENV.select do |k, _v|
      %w(line example tag pattern format out backtrace color profile warnings P e l t f o b c p w).include?(k)
    end
    cmds = [
      %w(rake gitlab:setup),
      "#{@rspec_w_overrides_command} #{arglist_string(arglist)}".split("\s")
    ]
    run_commands(cmds)
  end

  desc 'GITLAB | Run engine specs only'
  task :engine do
    arglist = ENV.select do |k, _v|
      %w(line example tag pattern format out backtrace color profile warnings P e l t f o b c p w).include?(k)
    end
    cmds = [
      %w(rake gitlab:setup),
      "#{@engine_command} #{arglist_string(arglist)}".split("\s")
    ]
    run_commands(cmds)
  end

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
task :rspec do
  arglist = ENV.select do |k, _v|
    %w(line example tag pattern format out backtrace color profile warnings P e l t f o b c p w).include?(k)
  end
  cmds = [
    %w(rake gitlab:setup),
    "#{@rspec_command} #{arglist_string(arglist)}".split("\s")
  ]
  run_commands(cmds)
end

def run_commands(cmds)
  cmds.each do |cmd|
    system({ 'RAILS_ENV' => 'test', 'force' => 'yes' }, *cmd) || fail("#{cmd} failed!")
  end
end

def arglist_string(arglist)
  arglist.map { |k, v| (k.length > 1 ? '--' :  '-') + "#{k} #{v}" }.join(' ')
end
