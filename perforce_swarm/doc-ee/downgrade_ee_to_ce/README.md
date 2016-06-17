# Downgrading from GitSwarm EE to GitSwarm

If you ever decide to downgrade your $GitSwarm$ back to GitSwarm, there
are a few steps you need take before installing the GitSwarm package on top
of the $GitSwarm$ package, or, if you are in an installation from source,
before you change remotes and fetch the latest CE code.

## Disable $GitSwarm$-only features

First thing to do is to disable the following features.

### Authentication mechanisms

Kerberos and Atlassian Crowd are only available for $GitSwarm$, so you
should disable these mechanisms before downgrading and you should provide
alternative authentication methods to your users.

### Git Annex

Git Annex is also only available for $GitSwarm$. This means that if you
have repositories that use Git Annex to store large files, these files will
no longer be easily available via Git. You should consider migrating these
repositories to use Git LFS before downgrading to GitSwarm.

### Remove Jenkins CI Service entries from the database

The `JenkinsService` class is only available for $GitSwarm$, so if you
downgrade to GitSwarm, you'll come across the following error:

```
Completed 500 Internal Server Error in 497ms (ActiveRecord: 32.2ms)

ActionView::Template::Error (The single-table inheritance mechanism failed to locate the subclass: 'JenkinsService'. This
error is raised because the column 'type' is reserved for storing the class in case of inheritance. Please rename this
column if you didn't intend it to be used for storing the inheritance class or overwrite Service.inheritance_column to
use another column for that information.)
```

All services are created automatically for every project you have, so in
order to avoid getting this error, you need to remove all instances of the
`JenkinsService` from your database:

**Package Installations**

```bash
sudo gitswarm-rails runner "Service.where(type: 'JenkinsService').delete_all"
```

**Source Installations**

```bash
bundle exec rails runner "Service.where(type: 'JenkinsService').delete_all" production
```

## Downgrade to GitSwarm

After performing the above mentioned steps, you are now ready to downgrade
your $GitSwarm$ installation to GitSwarm.

**Package Installations**

To downgrade a package installation, it is sufficient to install the
GitSwarm package on top of the currently installed one. You can do this
[manually](../install/manual_install.md),

**Source Installations**

To downgrade a source installation, you need to replace the current remote of
your GitLab installation with the Community Edition's remote, fetch the latest
changes, and checkout the latest stable branch:

```bash
git remote set-url origin git@gitlab.com:perforce/gitlab-ce.git
git fetch --all
git checkout release
```

Remember to follow the correct [update guides](../update/README.md) to make
sure all dependencies are up to date.
