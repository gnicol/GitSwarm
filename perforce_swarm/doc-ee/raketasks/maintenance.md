# Maintenance

## Gather information about GitSwarm EE and the system it runs on

This command gathers information about your GitSwarm EE installation and
the System it runs on. These may be useful when asking for help or
reporting issues.

```
sudo gitswarm-rake gitswarm:env:info
```

Example output:

```
System information
System:           Ubuntu 15.10
Current User:     git
Using RVM:        yes
RVM Version:      1.26.11
Ruby Version:     2.1.7p400
Gem Version:      2.4.8
Bundler Version:  1.11.2
Rake Version:     10.5.0
Sidekiq Version:  4.0.1

GitLab information
Version:          8.4.4
Revision:         af34fcc
Directory:        /opt/gitswarm/embedded/service/gitlab-rails
DB Adapter:       postgresql
URL:              https://gitlab.example.com
HTTP Clone URL:   https://gitlab.example.com/some-group/some-project.git
SSH Clone URL:    git@gitlab.example.com:some-group/some-project.git
Using LDAP:       no
Using Omniauth:   no

GitLab Shell
Version:          2.6.10
Repositories:     /var/opt/gitswarm/repositories/
Hooks:            /opt/gitswarm/embedded/service/gitlab-shell/hooks/
Git:              /usr/bin/git
```

## Check GitSwarm EE configuration

Runs the following rake tasks:

- `gitswarm:gitlab_shell:check`
- `gitswarm:sidekiq:check`
- `gitswarm:app:check`

These tasks check that each component was setup according to the
installation guide and suggest fixes for issues found.

You may also have a look at GitLab's [Trouble Shooting Guide](https://github.com/gitlabhq/gitlab-public-wiki/wiki/Trouble-Shooting-Guide).

```
sudo gitswarm-rake gitswarm:check
```

> Note: Use `SANITIZE=true` for gitswarm:check if you want to omit project
        names from the output.

Example output:

```
Checking Environment ...

Git configured for git user? ... yes
Has python2? ... yes
python2 is supported version? ... yes

Checking Environment ... Finished

Checking GitLab Shell ...

GitLab Shell version >= 2.6.10 ? ... OK (2.6.10)
Repo base directory exists? ... yes
Repo base directory is a symlink? ... no
Repo base owned by git:git? ... yes
Repo base access is drwxrws---? ... yes
hooks directories in repos are links: ... 
Running /opt/gitswarm/embedded/service/gitlab-shell/bin/check
Check GitLab API access: OK
Check directories and files: OK

Checking GitLab Shell ... Finished

Checking Sidekiq ...

Running? ... yes
Number of Sidekiq processes ... 1

Checking Sidekiq ... Finished

Checking Reply by email ...

Reply by email is disabled in config/gitlab.yml

Checking Reply by email ... Finished

Checking LDAP ...

LDAP is disabled in config/gitlab.yml

Checking LDAP ... Finished

Checking GitSwarm ...

Git configured with autocrlf=input? ... yes
Database config exists? ... yes
Database is SQLite ... no
All migrations up? ... yes
Database contains orphaned GroupMembers? ... no
GitLab config exists? ... yes
GitLab config outdated? ... no
Log directory writable? ... yes
Tmp directory writable? ... yes
Uploads directory setup correctly? ... skipped (no tmp uploads folder yet)
Init script exists? ... yes
Init script up-to-date? ... yes
Redis version >= 2.8.0? ... yes
Ruby version >= 2.1.0 ? ... yes (2.1.7)
Your git bin path is "/usr/bin/git"
Git version >= 1.7.10 ? ... yes (2.5.0)
Active users: 26

Checking GitSwarm ... Finished
```

## Rebuild authorized_keys file

In some case it is necessary to rebuild the `authorized_keys` file.

```
sudo gitswarm-rake gitswarm:shell:setup
```

```
This will rebuild an authorized_keys file.
You will lose any data stored in authorized_keys file.
Do you want to continue (yes/no)? yes
```

## Clear Redis cache

If for some reason the dashboard shows wrong information you might want to
clear Redis' cache.

```
sudo gitswarm-rake cache:clear
```
