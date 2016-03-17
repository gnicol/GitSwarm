[Help](../../README.md)
/ [Workflow](../README.md)
/ [Helix Mirroring](README.md)
/ Configuration

## Configuration

Before you can use Helix Mirroring, GitSwarm needs some configuration
that describes where the Git Fusion service(s) exist.

For Helix Mirroring, GitSwarm needs to be configured to connect to one or
more Git Fusion servers. GitSwarm always connects to a Git Fusion server as
a specific user, `gitswarm` if you don't specify otherwise. The "gitswarm"
user must exist in the Helix Versioning Engine as a standard user account
(not an `operator` or `service` user). The "gitswarm" user does not need
any special protections in the Helix Versioning Engine, but does require
read/write access to the `//.git-fusion` depot.

### Global Configuration

GitSwarm supports a special server entry called `global`, which contains
overrides for usernames, passwords, git configuration parameters, and
convention-based repository settings.

```ruby
gitswarm['git-fusion']['global']['user']      = 'global-user'
gitswarm['git-fusion']['global']['password']  = '<password for "global-user" user>'
gitswarm['git-fusion']['local']['url']        = 'http://gitswarm@gitfusion.host/'
gitswarm['git-fusion']['local']['password']   = '<password for "gitswarm" user>'
gitswarm['git-fusion']['development']['url']  = 'http://dev-gitfusion.host/'
gitswarm['git-fusion']['production']['url']   = 'http://prod-gitfusion.host/'
```

In the above example, the user `global-user` is used to log in to the
`development` and `production` Git Fusion servers. The user for the `local`
Git Fusion server remains as `gitswarm`.

> **Note:** Only `user`, `password`, `git_config_params`, `perforce['user']`,
> `perforce['password']` and `auto_create` settings can have global
> defaults. Global settings for `url` and `perforce['port']` is ignored if
> present.

> **Note:** The following priority is given to user/password lookups:
>
> 1.  Entry-specific user/password keys
> 1.  User/password specified on the Git Fusion server `url`
> 1.  Global user/password
> 1.  Default (`gitswarm` for user, `''` for password)

### Using an HTTP(S) connection

1.  **Edit the following configuration in `/etc/gitswarm/gitswarm.rb`:**

    After the `gitswarm['git-fusion']['enabled']` section:

    ```ruby
    gitswarm['git-fusion']['enabled']              = true
    gitswarm['git-fusion']['my_entry']['url']      = 'http://gitswarm@gitfusion.host/'
    gitswarm['git-fusion']['my_entry']['password'] = '<password for "gitswarm" user>'
    ```

    > **Note:** The "gitswarm" user needs to exist in the Helix Versioning
    > Engine that the Git Fusion service uses, and must have permission to
    > access the repositories you wish to import from.

    > **Note:** `my_entry` is an example key that is used to configure the
    > connection to a particular Git Fusion server. Similarly, you can
    > include configurations to other Git Fusion servers under other
    > uniquely-named keys.

    ```ruby
    gitswarm['git-fusion']['local']['url']      = 'http://gitswarm@gitfusion.host/'
    gitswarm['git-fusion']['local']['password'] = '<password for "gitswarm" user>'
    gitswarm['git-fusion']['other']['url']      = 'http://other-user@other-gitfusin.host/'
    gitswarm['git-fusion']['other']['password'] = '<password for "other-user" user>'
    ```

    > **Note:** While we do not recommend using self-signed SSL certificates
    > (and these should never be used in production), if you are using
    > self-signed certificates for HTTPS connections in a test environment,
    > you need to specify:

    ```ruby
    gitswarm['git-fusion']['my_entry']['git_config_params'] = 'http.sslVerify=false'
    ```

    > **Note:** the key `my_entry` can be replaced with a unique value of your
    > choosing.

1.  **Make the configuration change active:**

    ```bash
    sudo gitswarm-ctl reconfigure
    ```

### Using an SSH connection

1.  **Add the following configuration to `/etc/gitswarm/gitswarm.rb`:**

    ```ruby
    gitswarm['git-fusion']['enabled']               = true
    gitswarm['git-fusion']['my_entry']['url']       = 'git@gitfusion.host'
    gitswarm['git-fusion']['my_entry']['password']  = '<password for "gitswarm" user>'
    ```

1.  **Make this configuration change active:**

    ```bash
    sudo gitswarm-ctl reconfigure
    ```

    > **Note:** `reconfigure` also ensures that the "gitswarm" user has a
    > public SSH key.

To permit GitSwarm to connect to Git Fusion via SSH, follow these steps:

1.  **Get a copy of the `git` user's public SSH key from the GitSwarm host
    machine.**

    ```bash
    sudo cat ~git/.ssh/id_rsa.pub
    ```

    > **Note:** It is possible to modify the username of the system user that
    > GitSwarm-Shell uses. If you have modified the system username,
    > replace `git` in the command above with the configured username.

1.  **Install the `git` user's public SSH key in the Git Fusion service.**

    This process involves interacting with the Helix Versioning Engine that
    the Git Fusion service connects to. The steps are described in the [Git
    Fusion
    guide](http://www.perforce.com/perforce/doc.current/manuals/git-fusion/index.html),
    in the section [Authenticating Git Users using
    SSH](http://www.perforce.com/perforce/doc.current/manuals/git-fusion/appendix.ssh.html).

### Convention-based Repository Configuration

In order for GitSwarm to automatically create new Git Fusion repositories
when adding projects, GitSwarm needs to connect to the Helix Versioning
Engine (P4D) directly. GitSwarm also needs to be configured with a path
where it can place the repository files.

At a minimum, GitSwarm needs to be configured with a user id and password
for the connection. When using HTTP(S), this information should already be
present. When using SSH, you may need to add the settings:

```ruby
gitswarm['git-fusion']['enabled']              = true
gitswarm['git-fusion']['my_entry']['url']      = 'git@gitfusion.host'
gitswarm['git-fusion']['my_entry']['user']     = '<perforce-user-id>'
gitswarm['git-fusion']['my_entry']['password'] = '<password for "gitswarm" user>'
```

> **Note:** If no `port` is specified under the `perforce` key, GitSwarm
> connects to the given Git Fusion server and uses the same port as Git
> Fusion (the `my_entry` Git Fusion server in the above example).

If the auto-detected Perforce Port is incorrect, you may optionally specify
the appropriate value manually by setting:

```ruby
gitswarm['git-fusion']['my_entry']['perforce']['port']  = 'ssl:my-fusion:1666'
```

> **Note:** GitSwarm uses the following priority for determining
> user/password to connect to Perforce:
>
> 1.    Entry-specific user/password keys
> 1.    User/password specified on the Git Fusion server `url`
> 1.    Global user/password
> 1.    Default (`gitswarm` for user, `''` for password)

> **Note:** The user (e.g. `gitswarm`) needs to exist in the Helix
> Versioning Engine that the Git Fusion service uses, and must have
> permission to access the repositories you wish to import from.

> **Note:** The `my_entry` key is used to assign config values to a
> particular Git Fusion server. You can include more configured servers
> under other keys.

#### Auto-Create Configuration

GitSwarm generates a Git Fusion configuration and unique depot path for
each new project that has convention-based mirroring enabled. It constructs
these by substituting the GitSwarm project's namespace and project path
into a template that is specified in the configuration.

```ruby
gitswarm['git-fusion']['global']['auto_create']['path_template']      = '//gitswarm/projects/{namespace}/{project-path}'
gitswarm['git-fusion']['global']['auto_create']['repo_name_template'] = 'gitswarm-{namespace}-{project-path}'
```

> **Note:** `{namespace}` and `{project-path}` are substituted for the GitSwarm
> project's namespace and project path (name) when the project is created.

> **Note:** The depot specified in the `path_template` ('gitswarm' in the above
> example) must exist *prior* to attempting to use the convention-based
> repository feature. GitSwarm does *not* create this depot for you.

#### Sample Configuration

The following is a sample configuration for GitSwarm, including Helix
Versioning Engine integration, and auto-create settings:

```ruby
gitswarm['git-fusion']['enabled']                                       = true
gitswarm['git-fusion']['my_entry']['url']                               = 'git@gitfusion.host'
gitswarm['git-fusion']['my_entry']['user']                              = '<perforce-user-id>'
gitswarm['git-fusion']['my_entry']['password']                          = '<password for "gitswarm" user>'
gitswarm['git-fusion']['my_entry']['perforce']['port']                  = 'ssl:my-fusion:1666'
gitswarm['git-fusion']['my_entry']['auto_create']['path_template']      = '//gitswarm/projects/{namespace}/{project-path}'
gitswarm['git-fusion']['my_entry']['auto_create']['repo_name_template'] = 'gitswarm-{namespace}-{project-path}'
```
