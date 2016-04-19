# Changing your time zone

GitSwarm EE defaults its time zone to UTC. It has a global timezone
configuration parameter in `/etc/gitswarm/gitswarm.rb`.

To update, add the time zone that best applies to your location. Here are
two examples:

```ruby
gitlab_rails['time_zone'] = 'America/New_York'
```
or

```ruby
gitlab_rails['time_zone'] = 'Europe/Brussels'
```

To see all available time zones, run:

```bash
sudo gitswarm-rake time:zones:all
```

After you add or modify this field, reconfigure and restart:

```bash
sudo gitswarm-ctl reconfigure
sudo gitswarm-ctl restart
```
