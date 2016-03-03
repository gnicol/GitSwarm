# Installation

## Pre-installation steps

Use the following steps to prepare your system for installation of
GitSwarm EE:

1.  **Check if your server meets the [requirements](requirements.md).**

1.  **Acquire a license.**

    GitSwarm EE requires a valid subscription license. Certain features,
    such as the ability to push to a repository, are not available without
    a valid license. To request licenses, please contact your Perforce
    sales representative or email <sales@perforce.com>.

1.  **Adjust default firewall rules.**

    By default, the CentOS/RHEL firewall rules block HTTP and SSH access.

    1.  **For CentOS/RHEL 6.6+:**

        ```
sudo lokkit -s http -s ssh
        ```

    1.  **For CentOS/RHEL 7:**

        ```
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=ssh
sudo systemctl reload firewalld
        ```

1.  Optional: **Ensure that your system is up-to-date.**

    We advise installing GitSwarm EE on a fully up-to-date operating
    system:

    1.  **For Ubuntu (12.04 and 14.04):**

        ```
sudo apt-get update
sudo apt-get upgrade
        ```

    1.  **For CentOS/RHEL 6.6+ and 7:**

        ```
sudo yum update
        ```

1.  **Install a mail server and curl.**

    GitSwarm EE requires a local mail server to facilitate delivery of
    notifications via email, and `curl` is used in the [Quick
    install](#quick-install).

    Note: If you install Postfix, select `Internet Site` during setup. Do
    not use Exim to send email from GitSwarm EE.

    Then install your selected mail server. For example:

    1.  **For Ubuntu (12.04 and 14.04):**

        ```
sudo apt-get install postfix curl
        ```

    1.  **For CentOS/RHEL 6.6+:**

        ```
sudo yum install postfix curl
sudo service postfix start
sudo chkconfig postfix on
        ```

    1.  **For CentOS/RHEL 7:**

        ```
sudo yum install postfix curl
sudo systemctl enable postfix
sudo systemctl start postfix
        ```

## Quick install

```
curl -s https://package.perforce.com/bootstrap/gitswarm-ee.sh | sudo sh -
```

Perform the [post-installation](#post-installation) steps.

## Manual install

If you prefer to manually perform, or review, the steps undertaken by the
bootstrap script above, see the [Manual installation
steps](manual_install.md).

Perform the [post-installation](#post-installation) steps.

## Post-installation

1.  **Verify the external URL for your GitSwarm EE instance:**

    View `/etc/gitswarm/gitswarm.rb`, and verify that the following
    setting is set to the URL that your GitSwarm EE users should use:

    ```
external_url "http://gitswarm.example.com"
    ```

    Edit the setting if necessary.

1.  **Set the timezone for your GitSwarm EE instance:**

    Edit `/etc/gitswarm/gitswarm.rb`, and edit the line:

    ```
#gitlab_rails['time_zone'] = 'UTC'
    ```

    Replace `UTC` with an [appropriate
    timezone](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones), and uncomment the line.

1.  **Configure GitSwarm EE.**

    If you have made changes to `/etc/gitswarm/gitswarm.rb`, then you will
    want to run `reconfigure` for them to take effect.

    ```
sudo gitswarm-ctl reconfigure
    ```

1.  **Browse to the hostname and login.**

    ```
Username: root
Password: 5iveL!fe
    ```

1.  **Tweet about it!**

If you are interested, [learn about the GitSwarm EE directory
structure](structure.md).

To uninstall GitSwarm EE, follow the [uninstall steps](uninstall.md).

###  Additional Setup Options

*   **Set up the connection to your Helix Server:**

    GitSwarm EE automatically provisions a Helix Server and connects Helix
    Git Fusion for you when you initially install the GitSwarm EE packages.
    [Learn more about the provisioned server](auto_provision.md).

    In production, you will likely already have your own Helix Server
    already setup and will want to configure GitSwarm EE to talk to it in
    order to enable [project
    mirroring](../workflow/importing/import_from_gitfusion.md).

*   **Set up other ways of signing in:**

    Check out how to setup [LDAP](../integration/ldap.md) or
    [OmniAuth](../integration/omniauth.md)

### Troubleshooting

Note: For additional troubleshooting and configuration options, please see
the [Omnibus GitLab
readme](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md).

*   **error: "X" is an unknown key on CentOS/RHEL 6.6+**

    This error occurs during install of CentOS/RHEL 6.6+, often in a shared
    VM environment where some of the keys in `/etc/sysctl.conf` don't
    actually apply. The error usually looks something like this:

    ```
STDERR: error: "net.bridge.bridge-nf-call-ip6tables" is an unknown key
error: "net.bridge.bridge-nf-call-iptables" is an unknown key
error: "net.bridge.bridge-nf-call-arptables" is an unknown key
    ```

    These errors are ignorable, you just need to run `sudo gitswarm-ctl
    reconfigure`, and our script shouldn't have to modify that file again
    and will continue. If you want to future-proof upgrades from failing on
    the same lines, you can modify your `/etc/sysctl.conf` and comment out
    the keys that were listed as unknown.
