# Backup and restore

![backup banner](backup_hrz.png)

## Create a backup of the $GitSwarm$ system

A backup creates an archive file that contains the database, all
repositories and all attachments. This archive is saved in `backup_path`
(see `/etc/gitswarm/gitswarm.rb` for package installations, or
`config/gitlab.yml` for source installations).

The archive filename is constructed as `[TIMESTAMP]_gitswarm_backup.tar`.
This timestamp can be used to restore an specific backup. You can only
restore a backup to exactly the same version of $GitSwarm$ (or the
corresponding version of $GitLab$; see
[below](#restore-a-previously-created-backup) for details) that you created
it on, for example 2015.4. The best way to migrate your repositories from
one server to another is through backup restore.

You need to keep a separate copy of `/etc/gitswarm/gitlab-secrets.json`
(for package installations) or `/home/git/gitlab/.secret` (for source
installations). This file contains the database encryption key used
for two-factor authentication. If you restore a $GitSwarm$ backup without
restoring the database encryption key, users who have two-factor
authentication enabled lose access to your $GitSwarm$ server.

> Note: If you have enabled mirroring for any of your projects, you will
> need to backup any associated Helix server instances separately, *after*
> you have performed the $GitSwarm$ backup. See the [Backup and
> Recovery](https://www.perforce.com/perforce/doc.current/manuals/p4sag/chapter.backup.html)
> chapter in the [_Helix Versioning Engine Administrator Guide:
> Fundamentals_](https://www.perforce.com/perforce/doc.current/manuals/p4sag/index.html).

> Note: If you are using the `:auto_provisioned` Helix server instance
> (which we do not recommend for production systems), the following
> information may be helpful:

*   The auto provisioned Helix Server's 'P4ROOT' is
    `/var/opt/gitswarm/perforce/data`
*   The 'root' user can log in to the auto_provisioned Helix server with
    the $GitSwarm$ 'root' user's password
*   The auto provisioned Helix Server's 'p4d' binary is located under
    '/opt/perforce/sbin'

```bash
# Package installations
sudo gitswarm-rake gitswarm:backup:create

# Source installations
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production
```

Also you can choose what should be backed up by adding environment variable
SKIP. Available options: db, uploads (attachments), repositories, builds
(CI build output logs), artifacts (CI build artifacts), lfs (LFS objects).
Use a comma to specify several options at the same time.

```bash
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
Creating backup archive: $TIMESTAMP_gitswarm_backup.tar [DONE]
Deleting tmp directories...[DONE]
Deleting old backups... [SKIPPING]
```

## Upload backups to remote (cloud) storage

Starting with $GitSwarm$ 2015.4 you can let the backup script upload the
'.tar' file it creates. It uses the [Fog library](http://fog.io/) to
perform the upload. In the example below we use Amazon S3 for storage.  But
Fog also lets you use [other storage providers](http://fog.io/storage/).

For package installations:

```ruby
gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => 'eu-west-1',
  'aws_access_key_id' => 'AKIAKIAKI',
  'aws_secret_access_key' => 'secret123'
}
gitlab_rails['backup_upload_remote_directory'] = 'my.s3.bucket'
```

For source installations:

```yaml
  backup:
    # snip
    upload:
      # Fog storage connection settings, see http://fog.io/storage/ .
      connection:
        provider: AWS
        region: eu-west-1
        aws_access_key_id: AKIAKIAKI
        aws_secret_access_key: 'secret123'
      # The remote 'directory' to store your backups. For S3, this would be the bucket name.
      remote_directory: 'my.s3.bucket'
      # Turns on AWS Server-Side Encryption with Amazon S3-Managed Keys for backups, this is optional
      # encryption: 'AES256'
```

If you are uploading your backups to S3 you will probably want to create a new
IAM user with restricted access rights. To give the upload user access only for
uploading backups create the following IAM profile, replacing `my.s3.bucket`
with the name of your bucket:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1412062044000",
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::my.s3.bucket/*"
      ]
    },
    {
      "Sid": "Stmt1412062097000",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListAllMyBuckets"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "Stmt1412062128000",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my.s3.bucket"
      ]
    }
  ]
}
```

### Uploading to locally mounted shares

You may also send backups to a mounted share (`NFS` / `CIFS` / `SMB` /
etc.) by using the [`Local`](https://github.com/fog/fog-local#usage)
storage provider.  The directory pointed to by the `local_root` key
**must** be owned by the `git` user **when mounted** (mounting with the
`uid=` of the `git` user for `CIFS` and `SMB`) or the user that you are
executing the backup tasks under (for omnibus packages, this is the `git`
user).

The `backup_upload_remote_directory` **must** be set in addition to the
`local_root` key. This is the sub directory inside the mounted directory
that backups will be copied to, and will be created if it does not exist.
If the directory that you want to copy the tarballs to is the root of your
mounted directory, just use `.` instead.

For package installations:

```ruby
gitlab_rails['backup_upload_connection'] = {
  :provider => 'Local',
  :local_root => '/mnt/backups'
}

# The directory inside the mounted folder to copy backups to
# Use '.' to store them in the root directory
gitlab_rails['backup_upload_remote_directory'] = 'gitswarm_backups'
```

For source installations:

```yaml
  backup:
    # snip
    upload:
      # Fog storage connection settings, see http://fog.io/storage/ .
      connection:
        provider: Local
        local_root: '/mnt/backups'
      # The directory inside the mounted folder to copy backups to
      # Use '.' to store them in the root directory
      remote_directory: 'gitswarm_backups'
```

## Backup archive permissions

The backup archives created by $GitSwarm$ (123456_gitswarm_backup.tar)
should have owner/group git:git and 0600 permissions by default. This is
meant to avoid other system users reading $GitSwarm$'s data. If you need
the backup archives to have different permissions you can use the
'archive_permissions' setting.

```
# In /etc/gitswarm/gitswarm.rb, for package installations:
gitlab_rails['backup_archive_permissions'] = 0644 # Makes the backup archives world-readable
```

```
# In gitlab.yml, for source installations:
  backup:
    archive_permissions: 0644 # Makes the backup archives world-readable
```

## Storing configuration files

Please be informed that a backup does not store your configuration files.
One reason for this is that your database contains encrypted information
for two-factor authentication. Storing encrypted information along with
its key in the same place defeats the purpose of using encryption in the
first place!

If you use a package installation,please see the [instructions in the
readme to backup your
configuration](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md#backup-and-restore-omnibus-gitlab-configuration).
If you have a source installation, please consider backing up your
`.secret` file, `gitlab.yml` file, any SSL keys and certificates, and your
[SSH host
keys](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079).

At the very **minimum** you should backup
`/etc/gitswarm/gitlswarm-secrets.json` (package installations) or
`/home/git/gitlab/.secret` (source installations) to preserve your database
encryption key.

## Restore a previously created backup

You can only restore a backup to exactly the same version of $GitSwarm$
that you created it on, for example 2015.4.

### Prerequisites

You need to have a working $GitSwarm$ installation before you can perform a
restore. This is mainly because the system user performing the restore
actions ('git') is usually not allowed to create or delete the SQL database
it needs to import data into ('gitlabhq_production'). All existing data
will be either erased (SQL) or moved to a separate directory (repositories,
uploads).

If some or all of your $GitSwarm$ users are using two-factor authentication
(2FA) then you must also make sure to restore
`/etc/gitswarm/gitswarm-secrets.json` (package installations) or
`/home/git/gitlab/.secret` (source installations). Note that you need to
run `gitswarm-ctl reconfigure` after changing `gitswarm-secrets.json`.

### Source Installations

```
# Stop processes that are connected to the database
sudo service gitlab stop

bundle exec rake gitlab:backup:restore RAILS_ENV=production
```

Options:

```
BACKUP=timestamp_of_backup (required if more than one backup exists)
force=yes (do not ask if the authorized_keys file should get regenerated)
```

Example output:

```
Unpacking backup... [DONE]
Restoring database tables:
-- create_table("events", {:force=>true})
   -> 0.2231s
[...]
- Loading fixture events...[DONE]
- Loading fixture issues...[DONE]
- Loading fixture keys...[SKIPPING]
- Loading fixture merge_requests...[DONE]
- Loading fixture milestones...[DONE]
- Loading fixture namespaces...[DONE]
- Loading fixture notes...[DONE]
- Loading fixture projects...[DONE]
- Loading fixture protected_branches...[SKIPPING]
- Loading fixture schema_migrations...[DONE]
- Loading fixture services...[SKIPPING]
- Loading fixture snippets...[SKIPPING]
- Loading fixture taggings...[SKIPPING]
- Loading fixture tags...[SKIPPING]
- Loading fixture users...[DONE]
- Loading fixture users_projects...[DONE]
- Loading fixture web_hooks...[SKIPPING]
- Loading fixture wikis...[SKIPPING]
Restoring repositories:
- Restoring repository abcd... [DONE]
Deleting tmp directories...[DONE]
```

### Package installations

This procedure assumes that:

- You have installed the exact same version of $GitSwarm$ with which the
  backup was created
- You have run `sudo gitswarm-ctl reconfigure` at least once
- $GitSwarm$ is running. If not, start it using `sudo gitswarm-ctl start`.

First make sure your backup tar file is in the backup directory described
in the `/etc/gitswarm/gitswarm.rb` configuration
`gitlab_rails['backup_path']`. The default is `/var/opt/gitswarm/backups`.

```bash
sudo cp 1393513186_gitswarm_backup.tar /var/opt/gitswarm/backups/
```

Stop the processes that are connected to the database. Leave the rest of
$GitSwarm$ running:

```bash
sudo gitswarm-ctl stop unicorn
sudo gitswarm-ctl stop sidekiq
# Verify
sudo gitswarm-ctl status
```

Next, restore the backup, specifying the timestamp of the backup you wish
to restore:

```bash
# This command will overwrite the contents of your $GitSwarm$ database!
sudo gitswarm-rake gitswarm:backup:restore BACKUP=1393513186
```

Restart and check $GitSwarm$:

```shell
sudo gitswarm-ctl start
sudo gitswarm-rake gitswarm:check SANITIZE=true
```

If there is a $GitSwarm$ version mismatch between your backup tar file and the installed
version of $GitSwarm$, the restore command will abort with an error.
Install the [correct $GitSwarm$
version](https://www.gitlab.com/downloads/archives/) and try again.

## Configure cron to make daily backups

### For source installations:
```
cd /home/git/gitlab
sudo -u git -H editor config/gitlab.yml # Enable keep_time in the backup section to automatically delete old backups
sudo -u git crontab -e # Edit the crontab for the git user
```

Add the following lines at the bottom:

```
# Create a full backup of the $GitSwarm$ repositories and SQL database every day at 4am
0 4 * * * cd /home/git/gitlab && PATH=/usr/local/bin:/usr/bin:/bin bundle exec rake gitlab:backup:create RAILS_ENV=production CRON=1
```

The `CRON=1` environment setting tells the backup script to suppress all
progress output if there are no errors. This is recommended to reduce cron
spam.

### For package installations

To schedule a cron job that backs up your repositories and $GitSwarm$
metadata, use the root user:

```bash
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

> **Note:** This cron job does not [backup your
> $GitSwarm$configuration](#backup-and-restore-omnibus-gitlab-configuration)
> or [SSH host
> keys](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079).

## Alternative backup strategies

If your $GitSwarm$ server contains a lot of Git repository data you may
find the $GitSwarm$ backup script to be too slow. In this case you can
consider using filesystem snapshots as part of your backup strategy.

Example: Amazon EBS

> A $GitSwarm$ server using a package installation hosted on Amazon AWS.
> An EBS drive containing an ext4 filesystem is mounted at
> `/var/opt/gitswarm`. In this case you could make an application backup by
> taking an EBS snapshot. The backup includes all repositories, uploads and
> Postgres data.

Example: LVM snapshots + rsync

> A $GitSwarm$ server using a package installation, with an LVM logical
> volume mounted at `/var/opt/gitlab`. Replicating the `/var/opt/gitswarm`
> directory using rsync would not be reliable because too many files would
> change while rsync is running. Instead of rsync-ing `/var/opt/gitswarm`,
> we create a temporary LVM snapshot, which we mount as a read-only
> filesystem at `/mnt/gitswarm_backup`. Now we can have a longer running
> rsync job which will create a consistent replica on the remote server.
> The replica includes all repositories, uploads and Postgres data.

If you are running $GitSwarm$ on a virtualized server you can possibly also
create VM snapshots of the entire $GitSwarm$ server. It is not uncommon
however for a VM snapshot to require you to power down the server, so this
approach is probably of limited practical use.

## Troubleshooting

### Restoring database backup using omnibus packages outputs warnings

If you are using backup restore procedures you might encounter the
following warnings:

```
psql:/var/opt/gitswarm/backups/db/database.sql:22: ERROR:  must be owner of extension plpgsql
psql:/var/opt/gitswarm/backups/db/database.sql:2931: WARNING:  no privileges could be revoked for "public" (two occurrences)
psql:/var/opt/gitswarm/backups/db/database.sql:2933: WARNING:  no privileges were granted for "public" (two occurrences)

```

Be advised that, backup is successfully restored in spite of these warnings.

The rake task runs this as the `gitlab` user which does not have the
superuser access to the database. When restore is initiated it will also
run as `gitlab` user but it will also try to alter the objects it does not
have access to.  Those objects have no influence on the database
backup/restore but they give this annoying warning.

For more information see similar questions on postgresql issue
tracker[here](http://www.postgresql.org/message-id/201110220712.30886.adrian.klaver@gmail.com)
and
[here](http://www.postgresql.org/message-id/2039.1177339749@sss.pgh.pa.us)
as well as [stack
overflow](http://stackoverflow.com/questions/4368789/error-must-be-owner-of-language-plpgsql).

## Note

This documentation is for your installation of $GitSwarm$.
We backup GitLab.com and make sure your data is secure, but you can't use
these methods to export / backup your data yourself from GitLab.com.

Issues are stored in the database. They can't be stored in Git itself.

To migrate your repositories from one server to another with an up-to-date
version of $GitSwarm$, you can use the [import rake task](import.md) to do
a mass import of the repository. Note that if you do an import rake task,
rather than a backup restore, you will have all your repositories, but not
any other data.
