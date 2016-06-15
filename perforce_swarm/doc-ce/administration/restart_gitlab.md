# How to restart $GitSwarm$

Depending on how you installed $GitSwarm$, there are different methods to
restart its service(s).

If you want the TL;DR versions, jump to:

- [Package restart](#package-restart)
- [Package reconfigure](#package-reconfigure)
- [Source restart](#source-restart)

## Package installations

If you have used the [$GitSwarm$ packages][package-install] for
installation, then you should already have `gitswarm-ctl` in your `PATH`.

`gitswarm-ctl` interacts with the packages and can be used to restart
GitSwarm, specifically the Unicorn web server, as well as the other
components:

- GitLab Workhorse
- Sidekiq
- PostgreSQL (if you are using the bundled one)
- Nginx (if you are using the bundled one)
- Redis (if you are using the bundled one)
- [Mailroom][]
- Logrotate

### Package restart

There may be times in the documentation where you will be asked to
_restart_ $GitSwarm$. In that case, you need to run the following command:

```bash
sudo gitswarm-ctl restart
```

The output should be similar to this:

```
ok: run: gitlab-workhorse: (pid 11291) 1s
ok: run: logrotate: (pid 11299) 0s
ok: run: mailroom: (pid 11306) 0s
ok: run: nginx: (pid 11309) 0s
ok: run: postgresql: (pid 11316) 1s
ok: run: redis: (pid 11325) 0s
ok: run: sidekiq: (pid 11331) 1s
ok: run: unicorn: (pid 11338) 0s
```

To restart a component separately, you can append its service name to the
`restart` command. For example, to restart **only** Nginx you would run:

```bash
sudo gitswarm-ctl restart nginx
```

To check the status of $GitSwarm$ services, run:

```bash
sudo gitswarm-ctl status
```

Notice that all services say `ok: run`.

Sometimes, components time out during the restart and sometimes they get
stuck. In that case, you can use `gitswarm-ctl kill <service>` to send the
`SIGKILL` signal to the service, for example `sidekiq`. After that, a
restart should perform fine.

As a last resort, you can try to [reconfigure
$GitSwarm$](#package-reconfigure) instead.

### Package reconfigure

There may be times in the documentation where you will be asked to
_reconfigure_ $GitSwarm$. Remember that this method applies only for
package installations.

Reconfigure $GitSwarm$ with:

```bash
sudo gitswarm-ctl reconfigure
```

Reconfiguring $GitSwarm$ should occur in the event that something in its
configuration (`/etc/gitswarm/gitswarm.rb`) has changed.

When you run this command, [Chef], the underlying configuration management
application that powers $GitSwarm$, ensures that all directories,
permissions, services, etc., are in place and in the same shape that they
were initially shipped.

It also restarts $GitSwarm$ components where needed, if any of their
configuration files have changed.

If you manually edit any files in `/var/opt/gitswarm` that are managed by
Chef, running reconfigure reverts the changes AND restart the services that
depend on those files.

## Source restart

If you have followed the official installation guide to [install $GitSwarm$
from source][source-install], run the following command to restart
$GitSwarm$:

```bash
sudo service gitswarm restart
```

The output should be similar to this:

```
Shutting down GitLab Unicorn
Shutting down GitLab Sidekiq
Shutting down GitLab Workhorse
Shutting down GitLab MailRoom
...
GitLab is not running.
Starting GitLab Unicorn
Starting GitLab Sidekiq
Starting GitLab Workhorse
Starting GitLab MailRoom
...
The GitLab Unicorn web server with pid 28059 is running.
The GitLab Sidekiq job dispatcher with pid 28176 is running.
The GitLab Workhorse with pid 28122 is running.
The GitLab MailRoom email processor with pid 28114 is running.
GitLab and all its components are up and running.
```

This should restart Unicorn, Sidekiq, GitLab Workhorse and [Mailroom][]
(if enabled). The init service file that does all the magic can be found on
your server in `/etc/init.d/gitswarm`.

---

If you are using other init systems, like systemd, you can check the [GitLab
Recipes][gl-recipes] repository for some unofficial services. These are **not**
officially supported so use them at your own risk.

[package-install]: https://www.perforce.com/downloads/helix-gitswarm "Download $GitSwarm$ packages"
[source-install]: ../install/installation.md "Install $GitSwarm$ from source"
[mailroom]: ../incoming_email/README.md "Used for replying by email in $GitSwarm$ issues and merge requests"
[chef]: https://www.chef.io/chef/ "Chef official website"
[gl-recipes]: https://gitlab.com/gitlab-org/gitlab-recipes/tree/master/init "GitLab Recipes repository"
