## What is this?

These are a suite of tests designed to be pointed at a running GitSwarm instance which will perform some basic validation of it.
They will perform tests on the web front end, some git tests, some basic testing of mirroring to a Perforce server.

You need to:

- Copy config.yml.example to config.yml
- edit config.yml to configure appropriate settings, including the browser ( default phantom.js driver, which requires the latest installation of phantom.js. 
  Firefox would be the easiest out of the box solution to use), 
  the username, password of the GitSwarm instance you are connecting to. 
  The p4user, p4password and p4port fields should also be updated, mostly matching what was set in the gitswarm config.
- run 'rake' in this directory.
- this will run all .rb files under /spec which have names ending in _spec.rb