# Rake task to clear out the project tmp/tests directory. Can be used
# in rspec configuration to run before tests to avoid a manual cleaning
# step
namespace :perforce_swarm do
  desc 'Remove the tmp/tests directory'
  task :remove_tmp_tests do
    FileUtils.remove_dir(Rails.root.join('tmp', 'tests'), true)
  end
end
