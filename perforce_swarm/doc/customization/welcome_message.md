## GitSwarm welcome message example

In `/etc/gitswarm/gitswarm.rb`:

```ruby
gitlab_rails['extra_sign_in_text'] = <<'EOS'
# ACME GitSwarm
Welcome to the [ACME](http://www.example.com) GitSwarm server!
EOS
```

Run `sudo gitswarm-ctl reconfigure` for changes to take effect.

## Installation from source

In `/home/git/gitlab/config/gitlab.yml`:

```yaml
# snip
production:
  # snip
  extra:
    sign_in_text: |
      # ACME GitSwarm
      Welcome to the [ACME](http://www.example.com) GitSwarm server!
```

Run `sudo service gitswarm reload` for the change to take effect.
