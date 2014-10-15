require "perforce_swarm/engine"
if ENV['RAILS_ENV'] == 'test'
  require "perforce_swarm/spinach"
end