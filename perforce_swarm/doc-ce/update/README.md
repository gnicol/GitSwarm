# Updating GitSwarm to 2015.4

## Pre-update considerations

*  **Restoring backups**

   GitSwarm can only restore backups made on the same versions. This means a
   backup of GitSwarm 2015.3 can only be restored to an instance running 2015.3.

*  **Stopping GitSwarm**

   To ensure that GitSwarm's operations are stopped while the update takes
   place, you should manually stop GitSwarm before updating:

   ```
sudo gitswarm-ctl stop
   ```

## Performing the update to 2015.4

1.  **Download the 2015.4 GitSwarm package and install it.**

    ```
curl https://package.perforce.com/bootstrap/gitswarm.sh | sudo sh -
    ```

    The script should add the Perforce package repository, and install the
    latest version of GitSwarm. The upgrade will create a backup of your
    existing GitSwarm data before fully installing.

1.  **Check the application status.**

    Check if GitSwarm and its environment are configured correctly:
    ```
sudo gitswarm-rake gitswarm:check
    ```

# New configuration options

*  **Discovering new config options**

    GitSwarm doesn't update your `/etc/gitswarm/gitswarm.rb` for you, but we do
    include an updated example template:
    `/opt/gitswarm/etc/gitswarm.rb.template`. You can see what sort of config
    options have been changed since last release by running
    ```
sudo diff /etc/gitswarm/gitswarm.rb /opt/gitswarm/etc/gitswarm.rb.template
    ```

# For users upgrading FROM 2015.3

If you are upgrading from GitSwarm 2015.3 to 2015.4, and want to upgrade to the
latest version of the Helix Versioning Engine, you will need to perform
the following step:

    sudo apt-get remove perforce-gitswarm

# For users upgrading FROM 2015.1

## Post-upgrade steps

1.  **Create `gitswarm` user:**

    Before you can [import projects from Git
    Fusion](../workflow/importing/import_from_gitfusion.md), you need to
    manually create the `gitswarm` user within GitSwarm.
