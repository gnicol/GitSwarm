# Customize the complete sign-in page

Please see [Branded login page](branded_login_page.md)

# Add a welcome message to the sign-in page

It is possible to add a markdown-formatted welcome message to your GitSwarm
sign-in page.

## Example

In `/etc/gitswarm/gitswarm.rb`:

```ruby
gitlab_rails['extra_sign_in_text'] = <<'EOS'
# ACME GitSwarm
Welcome to the [ACME](http://www.example.com) GitSwarm server!
EOS
```

Run `sudo gitswarm-ctl reconfigure` for changes to take effect.
