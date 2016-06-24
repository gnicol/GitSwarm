# Changing your time zone

## Package installations

$GitSwarm$ uses UTC as the global time zone. The global time zone
configuration parameter can be changed in `/etc/gitswarm/gitswarm.rb`.

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

## Source installations

The global time zone configuration parameter can be changed in
`config/gitlab.yml`:

```
# time_zone: 'UTC'
```

Uncomment and customize if you want to change the default time zone of
$GitSwarm$.

To see all available time zones, run `bundle exec rake time:zones:all`.
