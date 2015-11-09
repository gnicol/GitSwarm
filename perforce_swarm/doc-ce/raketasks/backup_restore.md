# Backup restore

## Create a backup of the GitSwarm system

A backup creates an archive file that contains the database, all
repositories and all attachments. This archive will be saved in
`backup_path` (see `config/gitswarm.yml`). The filename will be
`[TIMESTAMP]_gitlab_backup.tar`. This timestamp can be used to restore a
specific backup. You can only restore a backup to exactly the same version
of GitSwarm that you created it on, for example 2015.3. The best way to
migrate your repositories from one server to another is through backup
restore.

**Note:** You need to keep a separate copy of the `/etc/gitswarm`
directory, as this contains the operational configuration of GitSwarm, and
encryption keys for the database (for users who have two-factor
authentiction enabled). See the [steps for configuration
backup](#storing-configuration-files).

**Note:** You need to backup the associated `p4d` instance separately, if
you have enabled mirroring for any of your projects. See TBW for details.

If you are interested in GitLab CI backup please follow to the [CI backup
documentation](https://gitlab.com/gitlab-org/gitlab-ci/blob/master/doc/raketasks/backup_restore.md)\*

## Performing the backup

```
sudo gitlab-rake gitlab:backup:create
```

Also you can choose what should be backed up by adding the environment
variable `SKIP`. Available options: `db`, `uploads` (attachments),
`repositories`. Use a comma to specify several options at the same time.

```
sudo gitlab-rake gitlab:backup:create SKIP=db,uploads
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
Creating backup archive: $TIMESTAMP_gitlab_backup.tar [DONE]
Deleting tmp directories...[DONE]
Deleting old backups... [SKIPPING]
```

## Upload backups to remote (cloud) storage

You can let the backup script upload the '.tar' file it creates. It uses
the [Fog library](http://fog.io/) to perform the upload. In the example
below we use Amazon S3 for storage, but Fog also lets you use [other
storage providers](http://fog.io/storage/).

```ruby
gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => 'eu-west-1',
  'aws_access_key_id' => 'AKIAKIAKI',
  'aws_secret_access_key' => 'secret123'
}
gitlab_rails['backup_upload_remote_directory'] = 'my.s3.bucket'
```

If you are uploading your backups to S3 you will probably want to create a
new IAM user with restricted access rights. To give the upload user access
only for uploading backups create the following IAM profile, replacing
`my.s3.bucket` with the name of your bucket:

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

## Backup archive permissions

The backup archives created by GitSwarm (123456_gitlab_backup.tar) have
owner/group `git:git` and `0600` permissions by default. This is meant to
avoid other system users reading GitSwarm's data. If you need the backup
archives to have different permissions you can use the
`archive_permissions` setting.

```
# In /etc/gitlab/gitlab.rb
gitlab_rails['backup_archive_permissions'] = 0644 # Makes the backup archives world-readable
```

## Storing configuration files

Please be aware that a backup does not store your configuration files.  One
reason for this is that your database contains encrypted information for
two-factor authentication. Storing encrypted information along with its key
in the same place defeats the purpose of using encryption in the first
place!

All of the configuration for GitSwarm is stored in `/etc/gitswarm`. To
backup your configuration:

```
# Creates a timestamped .tar file in the current directory
sudo sh -c 'umask 0077; tar -cf $(date "+etc-gitswarm-%s.tar") -C / etc/gitswarm
```

You can extract the .tar file as follows:

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

**Important: Do not store our GitSwarm application backups in the same place
as your configuration backup.** The configuration backup can contain
database encryption keys to protect sensitive data in the SQL database:

* GitSwarm two-factor authentiction (2FA) user secrets ('QR codes')
* GitLab CI 'secure variables'

If you keep your configuration backup in a different place from your
application data backup you reduce the chances of exposing the sensitive
data mentioned above in case one of your application backups is
lost/leaked/stolen.

## Restore a previously created backup

You can only restore a backup to exactly the same version of GitLab that
you created it on, for example 2015.3.

### Prerequisites

You need to have a working GitSwarm installation before you can perform a
restore. This is mainly because the system user performing the restore
actions ('git') is usually not allowed to create or delete the SQL database
it needs to import data into ('gitlabhq_production'). All existing data
will be either erased (SQL) or moved to a separate directory (repositories,
uploads).

If some or all of your GitLab users are using two-factor authentication
(2FA) then you must also make sure to restore
`/etc/gitlab/gitlab-secrets.json`. Note that you need to run `gitswarm-ctl
reconfigure` after changing `gitlab-secrets.json`.

### Omnibus installations

We will assume that you have installed GitSwarm and have run
`sudo gitswarm-ctl reconfigure` at least once.

First make sure your backup tar file is in `/var/opt/gitswarm/backups` (or wherever `gitlab_rails['backup_path']` points to).

```shell
sudo cp 1393513186_gitlab_backup.tar /var/opt/gitswarm/backups/
```

Next, restore the backup by running the restore command. You need to
specify the timestamp of the backup you are restoring.

```shell
# Stop processes that are connected to the database
sudo gitswarm-ctl stop unicorn
sudo gitswarm-ctl stop sidekiq

# This command will overwrite the contents of your GitSwarm database!
sudo gitswarm-rake gitswarm:backup:restore BACKUP=1393513186

# Start GitLab
sudo gitswarm-ctl start

# Check GitLab
sudo gitswarm-rake gitswarm:check SANITIZE=true
```

If there is a GitSwarm version mismatch between your backup tar file and
the installed version of GitSwarm, the restore command will abort with an
error.

## Configure cron to make daily backups

To schedule a cron job that backs up your repositories and GitSwarm
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
backups using all your disk space.  To do this add the following lines to
`/etc/gitswarm/gitswarm.rb` and reconfigure:

```
# limit backup lifetime to 7 days - 604800 seconds
gitlab_rails['backup_keep_time'] = 604800
```

NOTE: This cron job does not [backup your omnibus-gitlab
configuration](#backup-and-restore-omnibus-gitlab-configuration) or [SSH
host
keys](https://superuser.com/questions/532040/copy-ssh-keys-from-one-server-to-another-server/532079#532079).

## Alternative backup strategies

If your GitSwarm server contains a lot of git repository data you may find
the GitSwarm backup script to be too slow.  In this case you can consider
using filesystem snapshots as part of your backup strategy.

Example: Amazon EBS

> A GitLab server using omnibus-gitlab hosted on Amazon AWS. An EBS drive
> containing an ext4 filesystem is mounted at `/var/opt/gitswarm`. In this
> case you could make an application backup by taking an EBS snapshot. The
> backup includes all repositories, uploads and Postgres data.

Example: LVM snapshots + rsync

> A GitSwarm server with an LVM logical volume mounted at
> `/var/opt/gitswarm`. Replicating the `/var/opt/gitswarm` directory using
> rsync would not be reliable because too many files could change while
> rsync is running. Instead of rsync-ing `/var/opt/gitswarm`, we create a
> temporary LVM snapshot, which we mount as a read-only filesystem at
> `/mnt/gitswarm_backup`. Now we can have a longer running rsync job which
> will create a consistent replica on the remote server. The replica
> includes all repositories, uploads and Postgres data.

If you are running GitSwarm on a virtualized server you can possibly also
create VM snapshots of the entire GitSwarm server. It is not uncommon
however for a VM snapshot to require you to power down the server, so this
approach is probably of limited practical use.

## Troubleshooting

### Restoring database backup using omnibus packages outputs warnings

If you are using backup restore procedures you might encounter the
following warnings:

```
psql:/var/opt/gitswarm/backups/db/database.sql:22: ERROR:  must be owner of extension plpgsql
psql:/var/opt/gitswarm/backups/db/database.sql:2931: WARNING:  no privileges could be revoked for "public" (two occurences)
psql:/var/opt/gitswarm/backups/db/database.sql:2933: WARNING:  no privileges were granted for "public" (two occurences)
```

Be advised that, backup is successfully restored in spite of these
warnings.

The rake task runs this as the `gitlab` user which does not have the
superuser access to the database. When restore is initiated it will also
run as `gitlab` user but it will also try to alter the objects it does not
have access to. Those objects have no influence on the database
backup/restore but they give this annoying warning.

For more information see similar questions on postgresql issue
tracker[here](http://www.postgresql.org/message-id/201110220712.30886.adrian.klaver@gmail.com)
and
[here](http://www.postgresql.org/message-id/2039.1177339749@sss.pgh.pa.us)
as well as [stack
overflow](http://stackoverflow.com/questions/4368789/error-must-be-owner-of-language-plpgsql).

Issues are stored in the database. They are not stored using git.
