## Migrate GitLab CI to GitSwarm

Beginning with GitSwarm 2015.4, GitLab CI is no longer its own application,
but is instead built into GitSwarm.

This guide will detail the process of migrating your CI installation and
data into your GitSwarm installation. **You can only migrate CI data
from GitLab CI 8.0 to GitSwarm 2015.4; migrating between other versions
(e.g. 7.14 to 2016.1) is not possible.**

We recommend that you read through the entire migration process in this
document before beginning.

### Overview

In this document we assume you have a GitSwarm server and a GitLab CI
server. It does not matter if these are the same machine.

The migration consists of three parts: updating GitSwarm and GitLab CI,
moving data, and redirecting traffic.

Please note that CI builds triggered on your GitSwarm server in the time
between updating GitSwarm and finishing the migration will be lost. Your
GitSwarm server can be online for most of the procedure; the only GitSwarm
downtime (if any) is during the upgrade to 2015.4. Your CI service will be
offline from the moment you upgrade to 2015.4 until you finish the
migration procedure.

### Before upgrading

If **you don't want to migrate your existing data**:

```bash
mv /var/opt/gitswarm/gitlab-ci/builds /var/opt/gitswarm/gitlab-ci/builds.$(date +%s)
```

Run `sudo gitswarm-ctl reconfigure` and you can reach CI at `gitswarm.example.com/ci`.

If you want to migrate your existing data, continue reading.

#### 0. Updating from versions prior to 2015.4

If you are updating from older versions you should first update to 2015.4.
Otherwise it's pretty likely that you will encounter problems described in
the [Troubleshooting](#troubleshooting).

#### 1. Verify that backups work

Make sure that the backup script on both servers can connect to the
database.

```
# On your CI server:
sudo chown gitlab-ci:gitlab-ci /var/opt/gitswarm/gitlab-ci/builds
sudo gitlab-ci-rake backup:create
```

Also check on your GitSwarm server.

```
# On your GitSwarm server:
sudo gitswarm-rake gitswarm:backup:create SKIP=repositories,uploads
```

If this fails, you need to fix it before upgrading to 2015.4.

#### 2. Check source and target database types

Check what databases you use on your GitSwarm server and your CI server.
Look for the 'adapter:' line. If your CI server and your GitSwarm server
both use PostgreSQL, no special care is needed. If your CI server
uses MySQL, you need to pass a special option during the 'Moving data'
part.

```
# On your CI server:
sudo gitlab-ci-rake env:info
```

```
# On your GitSwarm server:
sudo gitswarm-rake gitswarm:env:info
```

#### 3. Storage planning

Decide where to store CI build traces on GitSwarm server. GitLab CI uses
files on disk to store CI build traces. The default path for these build
traces is `/var/opt/gitswarm/gitlab-ci/builds`. If you are storing your
repository data in a special location, or if you are using NFS, you should
make sure that you store build traces on the same storage as your Git
repositories.

### I. Upgrading

From this point on, GitLab CI will be unavailable for your end users.

#### 1. Upgrade GitSwarm to 2015.4.

First upgrade your GitSwarm server to version 2015.4.

#### 2. Disable CI on the GitSwarm server during the migration

After you update, go to the admin panel and temporarily disable CI.  As an
administrator, go to **Admin Area** -> **Settings**, and under **Continuous
Integration** uncheck **Disable to prevent CI usage until rake ci:migrate
is run (8.0 only)**.

#### 3. CI settings are now in GitSwarm

If you want to use custom CI settings (e.g. change where builds are
  stored), please update `/etc/gitswarm/gitswarm.rb`.

#### 4. Upgrade GitLab CI to 8.0

Now upgrade GitLab CI to version 8.0. If you have already installed
GitSwarm, this may have already happened.

#### 5. Disable GitLab CI on the CI server

Disable GitLab CI after upgrading to 8.0.

```
# On your CI server:
sudo gitswarm-ctl stop ci-unicorn
sudo gitswarm-ctl stop ci-sidekiq
```

### II. Moving data

#### 1. Database encryption key

Move the database encryption key from your CI server to your GitSwarm
server. The command below will show you what you need to copy-paste to
your GitSwarm server. You have to add a line to
`/etc/gitswarm/gitswarm.rb`.

```
# On your CI server:
sudo gitlab-ci-rake backup:show_secrets
```

#### 2. SQL data and build traces

Create your final CI data export. When the command finishes it will print
the path to your data export archive; you will need this file later.

```
# On your CI server:
sudo chown gitlab-ci:gitlab-ci /var/opt/gitswarm/gitlab-ci/builds
sudo gitlab-ci-rake backup:create
```

#### 3. Copy data to the GitSwarm server

If you were running GitSwarm and GitLab CI on the same server you can skip
this step.

Copy your CI data archive to your GitSwarm server. There are many ways to do
this, below we use SSH agent forwarding and 'scp', which will be easy and
fast for most setups. You can also copy the data archive first from the CI
server to your laptop and then from your laptop to the GitSwarm server.

```
# Start from your laptop
ssh -A ci_admin@ci_server.example
# Now on the CI server
scp /path/to/12345_gitlab_ci_backup.tar gitlab_admin@gitswarm_server.example:~
```

#### 4. Move data to the GitSwarm backups folder

Make the CI data archive discoverable for GitSwarm. We assume below that
you store backups in the default path, adjust the command if necessary.

```
# On your GitSwarm server:
sudo mv /path/to/12345_gitlab_ci_backup.tar /var/opt/gitswarm/backups/
```

#### 5. Import the CI data into GitSwarm.

This step will delete any existing CI data on your GitSwarm server. There
should be no CI data yet because you turned CI on the GitSwarm server off
earlier.

```
# On your GitSwarm server:
sudo chown git:git /var/opt/gitswarm/gitlab-ci/builds
sudo gitswarm-rake ci:migrate
```

#### 6. Restart GitSwarm

```
# On your GitSwarm server:
sudo gitswarm-ctl hup unicorn
sudo gitswarm-ctl restart sidekiq
```

### III. Redirecting traffic

If you were running GitLab CI using packages and you were using the
internal NGINX configuration your CI service should now be available both
at `ci.example.com` (the old address) and `gitswarm.example.com/ci`. **You
are done!**

If you installed GitLab CI from source we now need to configure a redirect
in NGINX so that existing CI runners can keep using the old CI server
address, and so that existing links to your CI server keep working.

#### 1. Update NGINX configuration

To ensure that your existing CI runners are able to communicate with the
migrated installation, and that existing build triggers still work, you'll
need to update your NGINX configuration to redirect requests for the old
locations to the new ones.

Edit `/etc/nginx/sites-available/gitlab_ci` and paste:

```nginx
# GITLAB CI
server {
  listen 80 default_server;         # e.g., listen 192.168.1.1:80;
  server_name YOUR_CI_SERVER_FQDN;  # e.g., server_name source.example.com;

  access_log  /var/log/nginx/gitlab_ci_access.log;
  error_log   /var/log/nginx/gitlab_ci_error.log;

  # expose API to fix runners
  location /api {
    proxy_read_timeout    300;
    proxy_connect_timeout 300;
    proxy_redirect        off;
    proxy_set_header      X-Real-IP $remote_addr;

    # You need to specify your DNS servers that are able to resolve YOUR_GITSWARM_SERVER_FQDN
    resolver 8.8.8.8 8.8.4.4;
    proxy_pass $scheme://YOUR_GITSWARM_SERVER_FQDN/ci$request_uri;
  }

  # redirect all other CI requests
  location / {
    return 301 $scheme://YOUR_GITSWARM_SERVER_FQDN/ci$request_uri;
  }

  # adjust this to match the largest build log your runners might submit,
  # set to 0 to disable limit
  client_max_body_size 10m;
}
```

Make sure you substitute these placeholder values with your real ones:

1. `YOUR_CI_SERVER_FQDN`: The existing public-facing address of your GitLab
   CI install (e.g., `ci.gitlab.com`).

1. `YOUR_GITSWARM_SERVER_FQDN`: The current public-facing address of your
   GitSwarm install (e.g., `gitswarm.example.com`).

**Make sure not to remove the `/ci$request_uri` part. This is required to
properly forward the requests.**

You should also make sure that you can:

1. `curl https://YOUR_GITSWARM_SERVER_FQDN/` from your previous GitLab CI
   server.
1. `curl https://YOUR_CI_SERVER_FQDN/` from your GitSwarm server.

#### 2. Check NGINX configuration

    sudo nginx -t

#### 3. Restart NGINX

    sudo /etc/init.d/nginx restart

#### Restore from backup

If something went wrong and you need to restore a backup, consult the
[Backup restoration](../raketasks/backup_restore.md) guide.

### Troubleshooting

#### show:secrets problem

If you see errors like this:

```
Missing `secret_key_base` or `db_key_base` for 'production' environment. The secrets will be generated and stored in `config/secrets.yml`
rake aborted!
Errno::EACCES: Permission denied @ rb_sysopen - config/secrets.yml
```

This can happen if you are updating from versions prior to 2015.3 straight
to 2015.4. The fix for this is to update to 2015.3 first and then update
GitSwarm EE to 2015.4.

#### Permission denied when accessing /var/opt/gitswarm/gitlab-ci/builds

To fix that issue you have to change `builds/` folder permission before
doing final backup:

```
sudo chown -R gitlab-ci:gitlab-ci /var/opt/gitswarm/gitlab-ci/builds
```

Then before executing `ci:migrate` you need to fix builds folder permission:

```
sudo chown git:git /var/opt/gitswarm/gitlab-ci/builds
```

#### Problems when importing CI database to GitSwarm

If you were migrating CI database from MySQL to PostgreSQL manually you can
see errors during import about missing sequences:

```
ALTER SEQUENCE
ERROR:  relation "ci_builds_id_seq" does not exist
ERROR:  relation "ci_commits_id_seq" does not exist
ERROR:  relation "ci_events_id_seq" does not exist
ERROR:  relation "ci_jobs_id_seq" does not exist
ERROR:  relation "ci_projects_id_seq" does not exist
ERROR:  relation "ci_runner_projects_id_seq" does not exist
ERROR:  relation "ci_runners_id_seq" does not exist
ERROR:  relation "ci_services_id_seq" does not exist
ERROR:  relation "ci_taggings_id_seq" does not exist
ERROR:  relation "ci_tags_id_seq" does not exist
CREATE TABLE
```

To fix that you need to apply this SQL statement before doing final backup:

```
gitlab-ci-rails dbconsole <<EOF
-- ALTER TABLES - DROP DEFAULTS
ALTER TABLE ONLY ci_application_settings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_builds ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_commits ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_events ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_jobs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_projects ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_runner_projects ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_runners ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_services ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_taggings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_tags ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_trigger_requests ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_triggers ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_variables ALTER COLUMN id DROP DEFAULT;
ALTER TABLE ONLY ci_web_hooks ALTER COLUMN id DROP DEFAULT;

-- ALTER SEQUENCES
ALTER SEQUENCE ci_application_settings_id_seq OWNED BY ci_application_settings.id;
ALTER SEQUENCE ci_builds_id_seq OWNED BY ci_builds.id;
ALTER SEQUENCE ci_commits_id_seq OWNED BY ci_commits.id;
ALTER SEQUENCE ci_events_id_seq OWNED BY ci_events.id;
ALTER SEQUENCE ci_jobs_id_seq OWNED BY ci_jobs.id;
ALTER SEQUENCE ci_projects_id_seq OWNED BY ci_projects.id;
ALTER SEQUENCE ci_runner_projects_id_seq OWNED BY ci_runner_projects.id;
ALTER SEQUENCE ci_runners_id_seq OWNED BY ci_runners.id;
ALTER SEQUENCE ci_services_id_seq OWNED BY ci_services.id;
ALTER SEQUENCE ci_taggings_id_seq OWNED BY ci_taggings.id;
ALTER SEQUENCE ci_tags_id_seq OWNED BY ci_tags.id;
ALTER SEQUENCE ci_trigger_requests_id_seq OWNED BY ci_trigger_requests.id;
ALTER SEQUENCE ci_triggers_id_seq OWNED BY ci_triggers.id;
ALTER SEQUENCE ci_variables_id_seq OWNED BY ci_variables.id;
ALTER SEQUENCE ci_web_hooks_id_seq OWNED BY ci_web_hooks.id;

-- ALTER TABLES - RE-APPLY DEFAULTS
ALTER TABLE ONLY ci_application_settings ALTER COLUMN id SET DEFAULT nextval('ci_application_settings_id_seq'::regclass);
ALTER TABLE ONLY ci_builds ALTER COLUMN id SET DEFAULT nextval('ci_builds_id_seq'::regclass);
ALTER TABLE ONLY ci_commits ALTER COLUMN id SET DEFAULT nextval('ci_commits_id_seq'::regclass);
ALTER TABLE ONLY ci_events ALTER COLUMN id SET DEFAULT nextval('ci_events_id_seq'::regclass);
ALTER TABLE ONLY ci_jobs ALTER COLUMN id SET DEFAULT nextval('ci_jobs_id_seq'::regclass);
ALTER TABLE ONLY ci_projects ALTER COLUMN id SET DEFAULT nextval('ci_projects_id_seq'::regclass);
ALTER TABLE ONLY ci_runner_projects ALTER COLUMN id SET DEFAULT nextval('ci_runner_projects_id_seq'::regclass);
ALTER TABLE ONLY ci_runners ALTER COLUMN id SET DEFAULT nextval('ci_runners_id_seq'::regclass);
ALTER TABLE ONLY ci_services ALTER COLUMN id SET DEFAULT nextval('ci_services_id_seq'::regclass);
ALTER TABLE ONLY ci_taggings ALTER COLUMN id SET DEFAULT nextval('ci_taggings_id_seq'::regclass);
ALTER TABLE ONLY ci_tags ALTER COLUMN id SET DEFAULT nextval('ci_tags_id_seq'::regclass);
ALTER TABLE ONLY ci_trigger_requests ALTER COLUMN id SET DEFAULT nextval('ci_trigger_requests_id_seq'::regclass);
ALTER TABLE ONLY ci_triggers ALTER COLUMN id SET DEFAULT nextval('ci_triggers_id_seq'::regclass);
ALTER TABLE ONLY ci_variables ALTER COLUMN id SET DEFAULT nextval('ci_variables_id_seq'::regclass);
ALTER TABLE ONLY ci_web_hooks ALTER COLUMN id SET DEFAULT nextval('ci_web_hooks_id_seq'::regclass);
EOF
```
