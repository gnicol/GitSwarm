# Updating GitSwarm to 2016.1

## Pre-update considerations

GitSwarm can only restore backups made on the same version. Hence, a backup
of GitSwarm 2015.4 can only be restored to an instance running 2015.4, and
not on 2016.1 or higher versions. Although, upgrading GitSwarm should not
result in data corruption, we recommend taking backups of your existing
version before you run an upgrade.

If you are using CentOS or RHEL, and have upgraded the OS distribution on
your GitSwarm server from 6.x to 7.x, you need to update the URL in the
Perforce repository configuration. For example, if
`/etc/yum.repos.d/perforce.repo` contains:

```
baseurl=http://package.perforce.com/yum/rhel/6/x86_64
```

you must edit that line to read:

```
baseurl=http://package.perforce.com/yum/rhel/7/x86_64
```

## Performing the update to 2016.1

1.  **Download the 2016.1 GitSwarm package and install it.**

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

# Upgrading from GitSwarm to GitSwarm EE

Before upgrading from GitSwarm to GitSwarm EE, please ensure you have read and
understand the [pre-update considerations](#pre-update-considerations).

1.  **Add Perforce's repository to your package configuration.**

    See [this document](https://www.perforce.com/perforce-packages) for
    instructions on adding Perforce's packaging key to your keyring, as well
    as adding the Perforce package repository to your package configuration.

1.  **Upgrade to GitSwarm EE**
    1.  **For Ubuntu (12.04 and 14.04):**

        ```
sudo apt-get remove helix-gitswarm
sudo apt-get clean
sudo apt-get install helix-gitswarm-ee
sudo gitswarm-ctl reconfigure
        ```

    1.  **For CentOS (6 and 7):**

        ```
sudo yum remove helix-gitswarm
sudo yum clean all
sudo yum install helix-gitswarm-ee
sudo gitswarm-ctl reconfigure
        ```

1.  **Check the application status.**

    Check if GitSwarm EE and its environment are configured correctly:
    ```
sudo gitswarm-rake gitswarm:check
    ```

# For users upgrading FROM 2015.1

## Post-upgrade steps

1.  **Create `gitswarm` user:**

    Before you can [import projects from Git
    Fusion](../workflow/importing/import_from_gitfusion.md), you need to
    manually create the `gitswarm` user within GitSwarm.
