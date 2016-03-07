# Kerberos integration

GitSwarm EE can be configured to allow your users to sign with their
Kerberos credentials. Kerberos integration can be enabled as a regular
omniauth provider, edit `/etc/gitswarm/gitswarm.rb` and restart GitSwarm
EE. You only need to specify the provider name. For example:

```
{ name: 'kerberos'}
```

You still need to configure your system for Kerberos usage, such as
specifying realms. GitSwarm EE makes use of the system's Kerberos settings.

Existing GitSwarm EE users can go to "Profile" \> "Account" and attach a
Kerberos account. If you want to allow users without a GitSwarm EE account
to login you should enable the option `omniauth_allow_single_sign_on` in
config file (default: `false`). Then, the first time a user signs in with
Kerberos credentials, GitSwarm EE creates a new GitSwarm EE user associated
with the email, which is built from the Kerberos username and realm. User
accounts are created automatically when authentication was successful.

### HTTP git access

A linked Kerberos account enables you to `git pull` and `git push` using
your Kerberos account, as well as your standard GitSwarm EE credentials.

### HTTP git access with Kerberos token (passwordless authentication)

GitSwarm EE users with a linked Kerberos account can also `git pull` and
`git push` using Kerberos tokens, i.e. without having to send their
password with each operation.

For GitSwarm EE to offer Kerberos token-based authentication, perform the
following prerequisites:

1.  Create a Kerberos Service Principal for the HTTP service on your
    GitSwarm EE server. If your GitSwarm EE server is
    `gitswarm.example.com` and your Kerberos realm `EXAMPLE.COM`, create a
    Service Principal
    `HTTP/gitswarm.example.com@EXAMPLE.COM` in your Kerberos database.

1.  Create a keytab for the above Service Principal, e.g.
    `/etc/http.keytab`.

The keytab is a sensitive file and must be readable by the GitSwarm EE
user. Set ownership and protect the file appropriately:

```bash
$ sudo chown git /etc/http.keytab
$ sudo chmod 0700 /etc/http.keytab
```

##### Configuration changes

In `/etc/gitswarm/gitswarm.rb`:

```ruby
gitlab_rails['kerberos_enabled'] = true
gitlab_rails['kerberos_keytab'] = "/etc/http.keytab"
```

and run `sudo gitswarm-ctl reconfigure` for changes to take effect.

#### Support for Git before 2.4

Until version 2.4, the `git` command uses only the `negotiate`
authentication method if the HTTP server offers it, even if this method
fails (such as when the client does not have a Kerberos token).  It is thus
not possible to fall back to username/password (also known as `basic`)
authentication if Kerberos authentication fails.

For GitSwarm EE users to be able to use either `basic` or `negotiate`
authentication with older git versions, it is possible to offer Kerberos
ticket-based authentication on a different port (e.g. 8443) while the
standard port continues offering only `basic` authentication.


* Edit `/etc/gitswarm/gitswarm.rb`:

```ruby
gitlab_rails['kerberos_use_dedicated_port'] = true
gitlab_rails['kerberos_port'] = 8443
gitlab_rails['kerberos_https'] = true
```

and run `sudo gitswarm-ctl reconfigure` for changes to take effect.

Git remote URLs have to be updated to
`https://gitswarm.example.com:8443/mygroup/myproject.git` in order to use
Kerberos ticket-based authentication.

#### Support for Active Directory Kerberos environments

When using Kerberos ticket-based authentication in an Active Directory
domain, it may be necessary to increase the maximum header size allowed by
nginx, as extensions to the Kerberos protocol may result in HTTP
authentication headers larger than the default size of 8kB. Configure
`large_client_header_buffers` to a larger value in [the nginx
configuration](http://nginx.org/en/docs/http/ngx_http_core_module.html#large_client_header_buffers).

### Helpful links to setup development kerberos environment.

https://help.ubuntu.com/community/Kerberos

http://blog.manula.org/2012/04/setting-up-kerberos-server-with-debian.html
