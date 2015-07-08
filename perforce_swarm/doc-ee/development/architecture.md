# GitSwarm EE Architecture Overview

## Software delivery

There are two editions of GitSwarm: 'GitSwarm', which is based upon
[GitLab's Community Edition](https://gitlab.com/gitlab-org/gitlab-ce/tree/master),
and 'GitSwarm Enterprise Edition (EE)', which is based upon
[GitLab's Enterprise Edition](https://about.gitlab.com/gitlab-ce/).

Both editions of GitSwarm are only available via packages.

Both editions of GitSwarm require a component called gitlab-shell.
It is included in the GitSwarm packages.

## Physical office analogy

You can imagine GitSwarm as a physical office.

**The repositories** are the goods (git repositories) that GitSwarm
handles. They can be stored in a "warehouse". This can be either a hard
disk, or something more complex, such as a NFS filesystem.

**Nginx** (a web server) acts like the front-desk. Users come to Nginx and
request actions to be done by workers in the office.

**The database** is a series of metal file cabinets with information on:
 - The goods in the warehouse (metadata, issues, merge requests etc);
 - The users coming to the front desk (permissions)

**Redis** is a communication board with "cubby holes" that can contain
tasks for office workers;

**Sidekiq** is a worker that primarily handles sending out emails.
It takes tasks from the Redis communication board;

**A Unicorn worker** is a worker that handles quick/mundane tasks. They
work with the communication board (Redis). Their job description:
 - Check permissions by checking the user session stored in a Redis "cubby
   hole".
 - Make tasks for Sidekiq.
 - Fetch stuff from the warehouse or move things around in there.

**Gitlab-shell** is a third kind of worker that takes orders from a fax
machine (SSH) instead of the front desk (HTTP). Gitlab-shell communicates
with Sidekiq via the "communication board" (Redis), and asks quick
questions of the Unicorn workers either directly or via the front desk.

**GitSwarm Enterprise Edition (the application)** is the collection of
processes and business practices that the office is run by.

## System Layout

When referring to ~git in the pictures it means the home directory of the
git user which is typically `/home/git`.

GitLab is primarily installed within the `/home/git` user home directory as
`git` user. Within the home directory is where the gitlabhq server software
resides as well as the repositories (though the repository location is
configurable).

The bare repositories are located in `/home/git/repositories`. GitSwarm is
a Ruby on Rails application, so the particulars of the inner workings can
be learned by studying how a Ruby on Rails application works.

To serve repositories over SSH there's an add-on application called
gitlab-shell which is installed in `/home/git/gitlab-shell`.

### Components

![GitSwarm Diagram Overview](gitswarm_diagram_overview.png)

A typical install of GitSwarm EE is on GNU/Linux. It uses Nginx as a web
front end to proxypass the Unicorn web server. By default, communication
between Unicorn and the front end is via a Unix domain socket, but
forwarding requests via TCP is also supported. The web front end accesses
`/home/git/gitlab/public`, bypassing the Unicorn server, to serve static
pages, uploads (e.g. avatar images or attachments), and precompiled
assets. GitSwarm EE serves web pages and a [GitSwarm API](../api/README.md)
using the Unicorn web server. It uses Sidekiq as a job queue which, in
turn, uses redis as a non-persistent database backend for job information,
meta data, and incoming jobs.

GitSwarm EE uses PostgreSQL for persistent database information (e.g.
users, permissions, issues, other meta data). GitSwarm EE stores the bare
git repositories it serves in `/home/git/repositories` by default. It also
keeps default branch and hook information with the bare repository.
`/home/git/gitlab-satellites` keeps checked out repositories when
performing actions such as a merge request, editing files in the web
interface, etc.

The satellite repository is used by the web interface for editing
repositories and the wiki which is also a git repository. When serving
repositories over HTTP/HTTPS GitSwarm EE utilizes the GitSwarm API to
resolve authorization and access as well as serving git objects.

The add-on component gitlab-shell serves repositories over SSH. It manages
the SSH keys within `/home/git/.ssh/authorized_keys` which should not be
manually edited. gitlab-shell accesses the bare repositories directly to
serve git objects and communicates with redis to submit jobs to Sidekiq for
GitSwarm EE to process. gitlab-shell queries the GitSwarm API to determine
authorization and access.

### Installation Folder Summary

To summarize here's the [directory structure of the `git` user home directory](../install/structure.md).

### Processes

    ps aux | grep '^git'

GitSwarm has several components to operate. As a system user (i.e. any user
that is not the `git` user) it requires a persistent database
(PostreSQL) and redis database. It also uses Nginx to proxypass Unicorn. As
the `git` user it starts Sidekiq and Unicorn (a simple Ruby HTTP server
running on port `8080` by default). Under the GitSwarm user there are
normally 4 processes: `unicorn_rails master` (1 process), `unicorn_rails
worker` (2 processes), `sidekiq` (1 process).

### Repository access

Repositories can be accessed via HTTP or SSH. HTTP cloning/push/pull
utilizes the GitSwarm API and SSH cloning is handled by gitlab-shell
(previously explained).

## Troubleshooting

See the README for more information.

### Init scripts of the services

The GitLab init script starts and stops Unicorn and Sidekiq.

```
/etc/init.d/gitswarm
Usage: service gitswarm {start|stop|restart|reload|status}
```

Redis (key-value store/non-persistent database)

```
/etc/init.d/redis
Usage: /etc/init.d/redis {start|stop|status|restart|condrestart|try-restart}
```

SSH daemon

```
/etc/init.d/sshd
Usage: /etc/init.d/sshd {start|stop|restart|reload|force-reload|condrestart|try-restart|status}
```

Web server

```
$ /etc/init.d/nginx
Usage: nginx {start|stop|restart|reload|force-reload|status|configtest}
```

Persistent database

```
$ /etc/init.d/postgresql
Usage: /etc/init.d/postgresql {start|stop|restart|reload|force-reload|status} [version ..]
```
