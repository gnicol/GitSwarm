# GitSwarm LDAP integration

GitSwarm can be configured to allow your users to sign with their LDAP
credentials to integrate with e.g. Active Directory.

The first time a user signs in with LDAP credentials, GitSwarm creates
a new GitSwarm user associated with the LDAP Distinguished Name (DN) of the
LDAP user.

GitSwarm user attributes, such as nickname and email, are copied from the
LDAP user entry.

## Security

GitSwarm assumes that LDAP users are not able to change their LDAP 'mail',
'email' or 'userPrincipalName' attribute. An LDAP user who is allowed to
change their email on the LDAP server can
[take over any account](#enabling-ldap-sign-in-for-existing-gitlab-users)
on your GitSwarm server.

We recommend against using GitSwarm LDAP integration if your LDAP users are
allowed to change their 'mail', 'email' or 'userPrincipalName' attribute on
the LDAP server.

If a user is deleted from the LDAP server, they will be blocked in GitSwarm
as well. Users will be immediately blocked from logging in. However, there
is an LDAP check cache time of one hour. The means users that are already
logged in or are using Git over SSH will still be able to access GitSwarm
for up to one hour. Manually block the user in the GitSwarm Admin area to
immediately block all access.

## Configuring GitSwarm for LDAP integration

To enable GitSwarm LDAP integration, you need to add your LDAP server
settings in `/etc/gitswarm/gitswarm.rb`. In GitSwarm Enterprise Edition,
you can have multiple LDAP servers connected to one GitSwarm server.

```ruby
gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load <<-EOS # remember to close this block with 'EOS' below
main: # 'main' is the GitSwarm 'provider ID' of this LDAP server
  ## label
  #
  # A human-friendly name for your LDAP server. It is OK to change the label later,
  # for instance if you find out it is too large to fit on the web page.
  #
  # Example: 'Paris' or 'Acme, Ltd.'
  label: 'LDAP'

  host: '_your_ldap_server'
  port: 389
  uid: 'sAMAccountName'
  method: 'plain' # "tls" or "ssl" or "plain"
  bind_dn: '_the_full_dn_of_the_user_you_will_bind_with'
  password: '_the_password_of_the_bind_user'

  # Set a timeout, in seconds, for LDAP queries. This helps avoid blocking
  # a request if the LDAP server becomes unresponsive.
  # A value of 0 means there is no timeout.
  timeout: 10

  # This setting specifies if LDAP server is Active Directory LDAP server.
  # For non AD servers it skips the AD specific queries.
  # If your LDAP server is not AD, set this to false.
  active_directory: true

  # If allow_username_or_email_login is enabled, GitSwarm will ignore everything
  # after the first '@' in the LDAP username submitted by the user on login.
  #
  # Example:
  # - the user enters 'jane.doe@example.com' and 'p@ssw0rd' as LDAP credentials;
  # - GitSwarm queries the LDAP server with 'jane.doe' and 'p@ssw0rd'.
  #
  # If you are using "uid: 'userPrincipalName'" on ActiveDirectory you need to
  # disable this setting, because the userPrincipalName contains an '@'.
  allow_username_or_email_login: false

  # To maintain tight control over the number of active users on your GitSwarm installation,
  # enable this setting to keep new users blocked until they have been cleared by the admin 
  # (default: false).
  block_auto_created_users: false

  # Base where we can search for users
  #
  #   Ex. ou=People,dc=gitswarm,dc=example
  #
  base: ''

  # Filter LDAP users
  #
  #   Format: RFC 4515 https://tools.ietf.org/search/rfc4515
  #   Ex. (employeeType=developer)
  #
  #   Note: GitSwarm does not support omniauth-ldap's custom filter syntax.
  #
  user_filter: ''

  # LDAP attributes that GitSwarm will use to create an account for the LDAP user.
  # The specified attribute can either be the attribute name as a string (e.g. 'mail'),
  # or an array of attribute names to try in order (e.g. ['mail', 'email']).
  # Note that the user's LDAP login will always be the attribute specified as `uid` above.
  attributes:
    # The username will be used in paths for the user's own projects
    # (like `gitswarm.example.com/username/project`) and when mentioning
    # them in issues, merge request and comments (like `@username`).
    # If the attribute specified for `username` contains an email address, 
    # the GitSwarm username will be the part of the email address before the '@'.
    username: ['uid', 'userid', 'sAMAccountName']
    email:    ['mail', 'email', 'userPrincipalName']

    # If no full name could be found at the attribute specified for `name`,
    # the full name is determined using the attributes specified for 
    # `first_name` and `last_name`.
    name:       'cn'
    first_name: 'givenName'
    last_name:  'sn'

# GitSwarm EE only: add more LDAP servers
# Choose an ID made of a-z and 0-9 . This ID will be stored in the database
# so that GitSwarm can remember which LDAP server a user belongs to.
# uswest2:
#   label:
#   host:
#   ....
EOS
```

If you are getting 'Connection Refused' errors when trying to connect to
the LDAP server please double-check the LDAP `port` and `method` settings
used by GitSwarm. Common combinations are `method: 'plain'` and `port: 389`, OR `method: 'ssl'` and `port: 636`.

## Enabling LDAP sign-in for existing GitSwarm users

When a user signs in to GitSwarm with LDAP for the first time, and their
LDAP email address is the primary email address of an existing GitSwarm
user, then the LDAP DN is associated with the existing user.

If the LDAP email attribute is not found in GitSwarm's database, a new user
is created.

In other words, if an existing GitSwarm user wants to enable LDAP sign-in
for themselves, they should check that their GitSwarm email address matches
their LDAP email address, and then sign into GitSwarm via their LDAP
credentials.

GitSwarm recognizes the following LDAP attributes as email addresses:
`mail`, `email` and `userPrincipalName`.

If multiple LDAP email attributes are present, e.g. `mail: foo@bar.com` and
`email: foo@example.com`, then the first attribute found wins -- in this
case `foo@bar.com`.

## Using an LDAP filter to limit access to your GitSwarm server

If you want to limit all GitSwarm access to a subset of the LDAP users on
your LDAP server you can set up an LDAP user filter. The filter must comply
with [RFC 4515](https://tools.ietf.org/search/rfc4515).

```ruby
# LDAP server syntax
gitlab_rails['ldap_servers'] = YAML.load <<-EOS
main:
  # snip...
  user_filter: '(employeeType=developer)'
EOS
```

Tip: if you want to limit access to the nested members of an Active
Directory group you can use the following syntax:

```
(memberOf:1.2.840.113556.1.4.1941:=CN=My Group,DC=Example,DC=com)
```

Please note that GitSwarm does not support the custom filter syntax used by
omniauth-ldap.

## Limitations

GitSwarm's LDAP client is based on
[omniauth-ldap](https://gitlab.com/gitlab-org/omniauth-ldap) which
encapsulates Ruby's `Net::LDAP` class. It provides a pure-Ruby
implementation of the LDAP client protocol. As a result, GitSwarm is
limited by `omniauth-ldap` and may impact your LDAP server settings.

### TLS Client Authentication  

Not implemented by `Net::LDAP`. So you should disable anonymous LDAP
authentication and enable simple or SASL authentication. TLS client
authentication setting in your LDAP server cannot be mandatory and clients
cannot be authenticated with the TLS protocol. 

### TLS Server Authentication  

Not supported by GitSwarm's configuration options. When setting `method:
ssl`, the underlying authentication method used by `omniauth-ldap` is
`simple_tls`. This method establishes TLS encryption with the LDAP server
before any LDAP-protocol data is exchanged but no validation of the LDAP
server's SSL certificate is performed.
