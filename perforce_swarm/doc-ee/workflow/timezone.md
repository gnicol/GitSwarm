# Changing your time zone

GitSwarm EE defaults its time zone to UTC. It has a global timezone
configuration parameter in `/etc/gitswarm/gitswarm.rb`.

To update, add the time zone that best applies to your location. Here are
two examples:
```
gitlab_rails['time_zone'] = 'America/New_York'
```
or
```
gitlab_rails['time_zone'] = 'Europe/Brussels'
```

To see all available time zones, run `bundle exec rake time:zones:all`.

After you add or modify this field, reconfigure and restart:
```
gitswarm-ctl reconfigure
gitswarm-ctl restart
```
