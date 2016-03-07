# Backup and restore

A backup creates an archive file that contains the database, all
repositories, and all attachments. This archive will be saved in
`backup_path` (find that configuration key within
`/etc/gitswarm/gitswarm.rb`).

The archive filename is constructed as `$TIMESTAMP_gitswarm_backup.tar`,
where `$TIMESTAMP` is the Unix time in seconds when the backup archive is
created. This timestamp can be used to restore a specific backup.

You can only restore a backup to exactly the same version of GitSwarm EE
(or the corresponding version of GitLab EE; see
[below](#restore-a-previously-created-backup) for details) that
it was created on, for example 2015.4. The best way to migrate your
repositories from one server to another is through backup/restore.

> Note: You need to keep a separate copy of the `/etc/gitswarm` directory,
        as this contains the operational configuration for GitSwarm EE, and
        encryption keys for the database (for users who have two-factor
        authentication enabled). See the [steps for configuration
        backup](#backup-the-configuration).

> Note: If you have enabled mirroring for any of your projects, you will
        need to backup any associated Helix server instances separately,
        *after* you have performed the GitSwarm EE backup. See the [Backup
        and
        Recovery](https://www.perforce.com/perforce/doc.current/manuals/p4sag/chapter.backup.html)
        chapter in the [_Helix Versioning Engine Administrator Guide:
        Fundamentals_](https://www.perforce.com/perforce/doc.current/manuals/p4sag/index.html).

> Note: If you are using the `:auto_provisioned` Helix server instance
        (which we do not recommend for production systems), the following
        information may be helpful:

*   The auto provisioned Helix Server's 'P4ROOT' is
    `/var/opt/gitswarm/perforce/data`
*   The 'root' user can log in to the auto_provisioned Helix server with
    the GitSwarm EE 'root' user's password
*   The auto provisioned Helix Server's 'p4d' binary is located under
    '/opt/perforce/sbin'

If you are interested in GitLab CI backup please follow to the [CI backup
documentation](https://gitlab.com/gitlab-org/gitlab-ci/blob/master/doc/raketasks/backup_restore.md)\*

> Important: We recommend that you store your backup files in a safe
             location, and at a secure offsite location as a disaster
             prevention measure.

## Creating a backup

```
sudo gitswarm-rake gitswarm:backup:create
```

You can choose what should be backed up by adding the environment
variable `SKIP`. Available options: `db`, `uploads` (attachments), and
`repositories`. Use a comma to specify several options at the same time.

```
sudo gitswarm-rake gitswarm:backup:create SKIP=db,uploads
```

Example output:

```
Dumping database tables:
- Dumping table events... [DONE]
- Dumping table issues... [DONE]
- Dumping table keys... [DONE]
- Dumping table merge_requests... [DONE]
- Dumping table milestones... [DONE]
- Dumping table namespaces... [DONE]
- Dumping table notes... [DONE]
- Dumping table projects... [DONE]
- Dumping table protected_branches... [DONE]
- Dumping table schema_migrations... [DONE]
- Dumping table services... [DONE]
- Dumping table snippets... [DONE]
- Dumping table taggings... [DONE]
- Dumping table tags... [DONE]
- Dumping table users... [DONE]
- Dumping table users_projects... [DONE]
- Dumping table web_hooks... [DONE]
- Dumping table wikis... [DONE]
Dumping repositories:
- Dumping repository abcd... [DONE]
Creating backup archive: 123456_gitswarm_backup.tar [DONE]
Deleting tmp directories...[DONE]
Deleting old backups... [SKIPPING]
```

### Backup archive permissions

The backup archives created by GitSwarm EE (123456_gitswarm_backup.tar)
have owner/group `git:git` and `0600` permissions by default. This is meant
to avoid other system users reading GitSwarm EE's data. If you need the
backup archives to have different permissions you can use the
`archive_permissions` setting.

```
# In /etc/gitswarm/gitswarm.rb
# 0644 makes the backup archives world-readable
gitlab_rails['backup_archive_permissions'] = 0644
```

### Backup the configuration

Please be aware that the backup task does not backup your GitSwarm EE
configuration. One reason for this is that your database contains encrypted
information for two-factor authentication. Storing encrypted information
along with its key in the same place defeats the purpose of using
encryption in the first place!

All of the configuration for GitSwarm EE is stored in `/etc/gitswarm`. To
backup your configuration:

```
# Creates a timestamped .tar file in the current directory
sudo sh -c 'umask 0077; tar -cf $(date "+etc-gitswarm-%s.tar") -C / etc/gitswarm
```

You can extract the `.tar` file as follows:

```
# Rename the existing /etc/gitswarm, if any
sudo mv /etc/gitswarm /etc/gitswarm.$(date +%s)
# Change the example timestamp below to match your configuration backup
sudo tar -xf etc-gitswarm-1399948539.tar -C /
```

Remember to run `sudo gitswarm-ctl reconfigure` after restoring a
configuration backup.

Note: Your machine's SSH host keys are stored separately in `/etc/ssh`. Be
sure to also [backup and restore those
keys](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079)
to avoid man-in-the-middle attack warnings if you have to perform a full
machine restore.

> Important: **Do not store your GitSwarm EE application backups in the
             same place as your configuration backup.** The configuration
             backup can contain database encryption keys to protect
             sensitive data in the SQL database:

* GitSwarm EE two-factor authentication (2FA) user secrets ('QR codes')
* GitLab CI 'secure variables'

If you keep your configuration backup in a different place from your
application data backup you reduce the chances of exposing the sensitive
data mentioned above in case one of your application backups is
lost/leaked/stolen.

### Configure cron to make daily backups

To schedule a cron job that backs up your repositories and GitSwarm EE
metadata, use the root user:

```
sudo su -
crontab -e
```

There, add the following line to schedule the backup for everyday at 2 AM:

```
0 2 * * * /opt/gitswarm/bin/gitswarm-rake gitswarm:backup:create CRON=1
```

You may also want to set a limited lifetime for backups to prevent regular
backups using all your disk space. To do this add the following lines to
`/etc/gitswarm/gitswarm.rb` and reconfigure:

```
# limit backup lifetime to 7 days - 604800 seconds
gitlab_rails['backup_keep_time'] = 604800
```

> Note: This cron job does not [backup your GitSwarm EE
        configuration](#backup-the-configuration) or [SSH host
        keys](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079).

## Restore a previously created backup

> Important: You can only restore a backup to GitSwarm EE if the backup was
             created on the same version of GitSwarm EE, or the
             corresponding version of GitLab EE.  For example, a backup
             taken on GitLab 8.0.5 can be restored to a 2015.4 GitSwarm EE
             install. Here is a list of the GitSwarm EE releases and their
             corresponding GitLab EE releases:
  * GitLab EE, 8.0.5 = GitSwarm EE 2015.4
  * GitLab EE, 8.4.5 = GitSwarm EE 2016.1

### Prerequisites

You need to have a working GitSwarm EE installation before you can perform
a restore. This is mainly because the system user performing the restore
actions ('git') is usually not allowed to create or delete the SQL database
it needs to import data into ('gitlabhq_production'). All existing data
will be either erased (SQL) or moved to a separate directory (repositories,
uploads).

If you are also restoring Helix Versioning Engine (P4D) backups, it is
better to restore Helix Versioning Engine before restoring GitSwarm EE.

If some or all of your GitLab users are using two-factor authentication
(2FA) then you must also make sure to restore the backup of the
configuration from `/etc/gitswarm`. Note that you need to run `gitswarm-ctl
reconfigure` after changing anything in `/etc/gitswarm`.

### Restoration procedure

We assume that you have installed GitSwarm EE and have run `sudo
gitswarm-ctl reconfigure` at least once.

1.  **Make sure your that backup `.tar` file is in the correct location.**

    The backup `.tar` file should appear in `/var/opt/gitswarm/backups` (or
    wherever `gitlab_rails['backup_path']` points to).

    ```bash
    sudo cp 1393513186_gitswarm_backup.tar /var/opt/gitswarm/backups/
    ```

1.  **Restore the backup by running the restore command.**

    You need to specify the timestamp of the backup you are restoring.

    1.  **Stop GitSwarm EE processes:**

        ```bash
        sudo gitswarm-ctl stop unicorn
        sudo gitswarm-ctl stop sidekiq
        ```

    1.  **Run the restoration task:**

        ```bash
        # This command overwrites the contents of your GitSwarm EE database!
        sudo gitswarm-rake gitswarm:backup:restore BACKUP=1393513186
        ```

    1.  **Restart GitSwarm EE processes:**

        ```bash
        sudo gitswarm-ctl start
        ```

    1.  **Check GitSwarm EE:**

        ```bash
        sudo gitswarm-rake gitswarm:check SANITIZE=true
        ```

If there is a GitSwarm EE version mismatch between your backup tar file and
the installed version of GitSwarm EE, the restore command aborts with an
error.

## Alternative backup strategies

If your GitSwarm EE server contains a lot of git repository data, you may
find the GitSwarm EE backup script to be too slow. In this case you can
consider using filesystem snapshots as part of your backup strategy.

Example: Amazon EBS

> A GitLab server using omnibus-gitlab hosted on Amazon AWS. An EBS drive
> containing an ext4 filesystem is mounted at `/var/opt/gitswarm`. In this
> case you could make an application backup by taking an EBS snapshot. The
> backup includes all repositories, uploads and Postgres data.

Example: LVM snapshots + rsync

> A GitSwarm EE server with an LVM logical volume mounted at
> `/var/opt/gitswarm`. Replicating the `/var/opt/gitswarm` directory using
> rsync would not be reliable because too many files could change while
> rsync is running. Instead of rsync-ing `/var/opt/gitswarm`, we create a
> temporary LVM snapshot, which we mount as a read-only filesystem at
> `/mnt/gitswarm_backup`. Now we can have a longer running rsync job which
> will create a consistent replica on the remote server. The replica
> includes all repositories, uploads and Postgres data.

If you are running GitSwarm EE on a virtualized server, you can possibly
also create VM snapshots of the entire GitSwarm EE server. It is not
uncommon however for a VM snapshot to require you to power down the server,
so this approach is probably of limited practical use.

## Troubleshooting

### Restoring database backup outputs warnings

During restoration, you might encounter the following warnings:

```
psql:/var/opt/gitswarm/backups/db/database.sql:22: ERROR:  must be owner of extension plpgsql
psql:/var/opt/gitswarm/backups/db/database.sql:2931: WARNING:  no privileges could be revoked for "public" (two occurences)
psql:/var/opt/gitswarm/backups/db/database.sql:2933: WARNING:  no privileges were granted for "public" (two occurences)
```

Be advised that, the restoration is successful in spite of these warnings.

The rake task runs this as the `git` user which does not have the superuser
access to the database. When restore is initiated it will also run as `git`
user but it will also try to alter the objects it does not have access to.
Those objects have no influence on the database backup/restore but they
give this annoying warning.

For more information see similar questions on postgresql issue tracker
[here](http://www.postgresql.org/message-id/201110220712.30886.adrian.klaver@gmail.com)
and
[here](http://www.postgresql.org/message-id/2039.1177339749@sss.pgh.pa.us)
as well as [Stack
Overflow](http://stackoverflow.com/questions/4368789/error-must-be-owner-of-language-plpgsql).

### Issue storage

Issues are stored in the database. They are not stored using git.
