# How to restart GitSwarm

Depending on how you installed GitSwarm, there are different methods to
restart its service(s).

If you want the TL;DR versions, jump to:

- [Restart](#restart)
- [Reconfigure](#reconfigure)

`gitswarm-ctl` can be used to restart the GitSwarm application (Unicorn) as
well as the other components, like:

- GitLab Workhorse
- Sidekiq
- PostgreSQL (if you are using the bundled one)
- NGINX (if you are using the bundled one)
- Redis (if you are using the bundled one)
- [Mailroom]
- Logrotate

## Restart

There may be times in the documentation where you are asked to _restart_
GitSwarm. In that case, you need to run the following command:

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
`restart` command. For example, to restart **only** NGINX you would run:

```bash
sudo gitswarm-ctl restart nginx
```

To check the status of GitSwarm services, run:

```bash
sudo gitswarm-ctl status
```

Notice that all services say `ok: run`.

Sometimes, components time out during the restart and sometimes they get
stuck. In that case, you can use `gitswarm-ctl kill <service>` to send the
`SIGKILL` signal to the service, for example `sidekiq`. After that, a
restart should perform fine.

As a last resort, you can try to [reconfigure](#reconfigure) instead.

## Reconfigure

There may be times in the documentation where you are asked to
_reconfigure_ GitSwarm.

Reconfigure GitSwarm with:

```bash
sudo gitswarm-ctl reconfigure
```

Reconfiguring GitSwarm should occur in the event that something in its
configuration (`/etc/gitswarm/gitswarm.rb`) has changed.

When you run this command, [Chef], the underlying configuration management
application that powers GitSwarm, ensures that all directories,
permissions, services, etc., are in place and in the same shape that they
were initially shipped.

It also restarts GitSwarm components where needed, if any of their
configuration files have changed.

If you manually edit any files in `/var/opt/gitswarm` that are managed by
Chef, running reconfigure reverts the changes AND restarts the services
that depend on those files.

[omnibus-dl]: https://about.gitlab.com/downloads/ "Download the Omnibus packages"
[mailroom]: ../incoming_email/README.md "Used for replying by email in GitSwarm issues and merge requests"
[chef]: https://www.chef.io/chef/ "Chef official website"
[src-service]: https://gitlab.com/gitlab-org/gitlab-ce/blob/master/lib/support/init.d/gitlab "GitLab init service file"
[gl-recipes]: https://gitlab.com/gitlab-org/gitlab-recipes/tree/master/init "GitLab Recipes repository"
