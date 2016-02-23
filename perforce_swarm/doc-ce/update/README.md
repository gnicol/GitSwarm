# Updating GitSwarm to 2016.1

## Pre-update considerations

GitSwarm can only restore backups made on the same version. Hence, a backup
of GitSwarm 2015.4 can only be restored to an instance running 2015.4, and
not on 2016.1 or higher versions. Although, upgrading GitSwarm should not
result in data corruption, we recommend taking backups of your existing
version before you run an upgrade.

## Update dependencies

If you have any repos mirroring their content into Helix Git Fusion, we
recommend that you update Helix Git Fusion and the Helix Versioning Engine
prior to updating GitSwarm.

-   **For Ubuntu:**

    ```bash
    sudo apt-get upgrade helix-git-fusion helix-cli-base helix-p4d-base
    ```

-   **For CentOS:**

    ```bash
    sudo yum update helix-git-fusion helix-cli-base helix-p4d-base
    ```

## Performing the update to 2016.1

1.  **Download the 2016.1 GitSwarm package and install it.**

    ```bash
    curl https://package.perforce.com/bootstrap/gitswarm.sh | sudo sh -
    ```

    The script should add the Perforce package repository, and install the
    latest version of GitSwarm. The upgrade will create a backup of your
    existing GitSwarm data before fully installing.

1.  **Check the application status.**

    Check if GitSwarm and its environment are configured correctly:

    ```bash
    sudo gitswarm-rake gitswarm:check
    ```

# New configuration options

*  **Discovering new config options**

    GitSwarm doesn't update your `/etc/gitswarm/gitswarm.rb` for you, but
    we do include an updated example template:
    `/opt/gitswarm/etc/gitswarm.rb.template`. You can see what sort of
    config options have been changed since last release by running:

    ```bash
    sudo diff /etc/gitswarm/gitswarm.rb /opt/gitswarm/etc/gitswarm.rb.template
    ```

# Upgrading from GitSwarm to GitSwarm EE

Before upgrading from GitSwarm to GitSwarm EE, please ensure you have read
and understand the [pre-update considerations](#pre-update-considerations).

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

    ```bash
    sudo gitswarm-rake gitswarm:check
    ```
