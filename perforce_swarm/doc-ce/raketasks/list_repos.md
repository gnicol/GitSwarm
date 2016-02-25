# Listing repository directories

You can print a list of all Git repositories on disk managed by GitSwarm
with the following command:

```bash
sudo gitswarm-rake gitswarm:list_repos
```

If you only want to list projects with recent activity you can pass a date
with the 'SINCE' environment variable. The time you specify is parsed by
the Rails [TimeZone#parse
function](http://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html#method-i-parse).

```bash
sudo gitswarm-rake gitswarm:list_repos SINCE='Sep 1 2015'
```

Note that the projects listed are NOT sorted by activity; they use the
default ordering of the GitSwarm application.
