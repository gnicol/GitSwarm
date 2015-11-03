# Migration from GitLab

## Introduction

If you already have a deployed GitLab instance with existing projects, but wish to use GitSwarm, it is possible to
migrate your GitLab data (workflow + Git repositories) over to GitSwarm. This will allow you to have the complete and
supported offering from one vendor, as well as leveraging Perforce Helix as the master for all assets.

## Requirements

1.  **An existing GitLab install**
    Only the following versions of GitLab are supported for migration:

    |CE|8.0.5|
    |---|---|
    |EE|unsupported?|

    If the GitLab instance you're looking to migrate from is not on the above list, you will need to follow
    [these instructions](/help/update/README.md) to up/downgrade as necessary to a supported version.
    This is a hard requirement; the migration process **will not work** unless your GitLab
    instance version is one of the above.

1.  **A new up-to-date GitSwarm install**
    Only the following versions of GitSwarm are supported for migration:

    |GitSwarm|15.4|
    |---|---|

    If the GitSwarm instance you're looking to migrate to is not on the above list, you will need to follow
    [these instructions](/help/update/README.md) to upgrade as necessary to a supported version. This is a hard requirement;
    the migration process **will not work** unless your GitSwarm instance version is one of the above.

    Migrating to an existing GitSwarm (one that has existing users, projects and repositories) will result in this
    data being overwritten and/or destroyed during the migration. It is high recommended that you only migrate to a
    new GitSwarm instance to avoid this issue.

1.  **Recommended Approach**
    The recommended approach is to upgrade your GitLab instance to the latest version, and ensure your target GitSwarm
    instance is also on the latest version.

## Migration Process

1. **Perform a backup of your source GitLab instance**

    Follow [these instructions](http://doc.gitlab.com/ce/raketasks/backup_restore.html) to perform a backup on the
    GitLab instance from which you are migrating.

    After the backup process is complete, it will report the name of the backup file created:
        ...
        done
        Dumping uploads ...
        done
        Dumping builds ...
        done
        Creating backup archive: 1446498774_gitlab_backup.tar ... done
        Uploading backup archive to remote storage  ... skipped
        ...

    It is important to note the name of the backup file in the above output, as well as the timestamp (numeric)
    portion of the file. In the above case, the file is called ```1446498774_gitlab_backup.tar``` and the
    timestamp portion of the file is ```1446498774```.

1. **Copy the backup archive to the destination GitSwarm instance**

    The backup process above will result in the creation of a .tar file, which contains a backup of your workflow
    (users, projects, merge requests) as well as the actual Git repositories. You will need to copy the file created
    above to the GitSwarm instance you are restoring to, and place the file under ```/var/opt/gitswarm/backups/```.

1. **Restore the backup archive against the destination GitSwarm instance**

    Follow [these instructions](/help/raketasks/backup_restore.md#restore-a-previously-created-backup) for
    restoring the backup on your GitSwarm instance, ensuring that you use the correct ```TIMESTAMP``` value that you
    made note of in step 1 of the migration process.

    This process will restore the database, upgrade it to the latest GitSwarm schema, and then restore any backed-up
    repositories to your GitSwarm instance. Once the backup process is complete and your GitSwarm instance has been
    (re)started, you can then continue with configuring [mirroring in Helix](/help/workflow/importing/import_from_gitfusion.md)
    for your projects, to gain the full benefit of using GitSwarm.

## Additional Help

1.  **When I perform the restore step of the migration, I get the following error/warnings:**

    psql:/var/opt/gitlab/backups/db/database.sql:22: ERROR:  must be owner of extension plpgsql
    psql:/var/opt/gitlab/backups/db/database.sql:2931: WARNING:  no privileges could be revoked for "public" (two occurences)
    psql:/var/opt/gitlab/backups/db/database.sql:2933: WARNING:  no privileges were granted for "public" (two occurences)

    Please see [/help/raketasks/backup_restore.md#restoring-database-backup-using-omnibus-packages-outputs-warnings](this document)
