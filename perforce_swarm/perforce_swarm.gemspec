$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'perforce_swarm/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'perforce_swarm'
  s.version     = PerforceSwarm::VERSION
  s.authors     = 'Perforce Software'
  s.email       = 'support@perforce.com'
  s.homepage    = 'http://perforce.com'
  s.summary     = 'Perforce Swarm enhancements for GitLab'
  s.description = 'Perforce Swarm enhancements for GitLab'

  s.files = Dir['{app,config,db,lib}/**/*']

  s.add_dependency 'rails', '~> 4.2.4'
end
