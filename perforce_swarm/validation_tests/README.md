## What is this?

These are a suite of tests designed to be pointed at a running GitSwarm instance which will perform some basic validation of it.
They will perform tests on the web front end, some git tests, some basic testing of mirroring to a Perforce server.

You need to:

- edit config.yml to configure appropriate settings
- run 'rake' in this directory.
- this will run all .rb files under /test which have names ending in _test.rb