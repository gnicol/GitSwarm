# Check Rake Tasks

## Repository Integrity

Even though Git is very resilient and tries to prevent data integrity
issues, there are times when things go wrong. The following Rake tasks
intend to help GitSwarm administrators diagnose problem repositories so
they can be fixed.

There are 3 things that are checked to determine integrity.

1. Git repository file system check ([git
   fsck](https://git-scm.com/docs/git-fsck)). This step verifies the
   connectivity and validity of objects in the repository.

1. Check for `config.lock` in the repository directory.

1. Check for any branch/references lock files in `refs/heads`.

It's important to note that the existence of `config.lock` or reference
locks alone do not necessarily indicate a problem. Lock files are routinely
created and removed as Git and GitSwarm perform operations on the
repository. They serve to prevent data integrity issues. However, if a Git
operation is interrupted these locks may not be cleaned up properly.

The following symptoms may indicate a problem with repository integrity. If
users experience these symptoms you may use the rake tasks described below
to determine exactly which repositories are causing the trouble.

- Receiving an error when trying to push code -
  `remote: error: cannot lock ref`

- A 500 error when viewing the GitSwarm dashboard or when accessing a
  specific project.

### Check all GitLab repositories

This task loops through all repositories on the GitSwarm server and runs
the 3 integrity checks described previously.

```bash
sudo gitswarm-rake gitswarm:repo:check
```

Example output:

```
Checking repo at
/var/opt/gitswarm/git-data/repositories/root/prj2-mirror.wiki.git
Running `git fsck`
notice: HEAD points to an unborn branch (master)
Checking object directories: 100% (256/256), done.
notice: No default references
'config.lock' file exists? ... no
No ref lock files exist
```

### Check repositories for a specific user

This task checks all repositories that a specific user has access to. This
is important because sometimes you know which user is experiencing trouble
but you don't know which project might be the cause.

If the rake task is executed without brackets at the end, you are prompted
to enter a username.

```bash
sudo gitswarm-rake gitswarm:user:check_repos
sudo gitswarm-rake gitswarm:user:check_repos[<username>]
```

Example output:

```
Checking repo at /var/opt/gitswarm/git-data/repositories/root/lfs-test2.git
Running `git fsck`
Checking object directories: 100% (256/256), done.
'config.lock' file exists? ... no
No ref lock files exist

Checking repo at /var/opt/gitswarm/git-data/repositories/root/lfs-test.git
Running `git fsck`
Checking object directories: 100% (256/256), done.
'config.lock' file exists? ... yes
No ref lock files exist

Checking repo at /var/opt/gitswarm/git-data/repositories/root/gitlab-recipes.git
Running `git fsck`
Checking object directories: 100% (256/256), done.
Checking objects: 100% (2187/2187), done.
'config.lock' file exists? ... yes
Ref lock files exist:
  /var/opt/gitswarm/git-data/repositories/root/gitlab-recipes.git/refs/heads/master.lock
```
