require 'perforce_swarm/active_support/concern'
require 'perforce_swarm/engine'
require 'perforce_swarm/spinach' if ENV['RAILS_ENV'] == 'test'
require 'perforce_swarm/rspec'   if ENV['RAILS_ENV'] == 'test'
