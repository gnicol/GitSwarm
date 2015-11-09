# Installation

Use the following steps to prepare your system for installation of
GitSwarm:

1.  **Check if your server meets the [requirements](requirements.md).**

1.  **Ensure that your system is up-to-date.**

    We advise installing GitSwarm on a fully up-to-date operating system:

    1.  **For Ubuntu (12.04 and 14.04):**

        ```
sudo apt-get update
sudo apt-get upgrade
        ```

    1.  **For CentOS 6:**

        ```
sudo yum update
sudo lokkit -s http -s ssh
        ```
        Note: The commands above also open HTTP and SSH access in the
        system firewall.

    1.  **For CentOS 7:**

        ```
sudo yum update
sudo firewall-cmd --permanent --add-service=http
sudo systemctl reload firewalld
        ```
        Note: The commands above also open HTTP access in the system
        firewall.

1.  **Install a mail server and curl.**

    GitSwarm requires a local mail server to facilitate delivery of
    notifications via email, and `curl` is used in the [Quick
    install](#quick-install).

    Note: If you install Postfix, select `Internet Site` during setup. Do
    not use Exim to send email from GitSwarm.

    Then install your selected mail server. For example:

    1.  **For Ubuntu (12.04 and 14.04):**

        ```
sudo apt-get postfix curl
        ```

    1.  **For CentOS 6:**

        ```
sudo yum install postfix curl
sudo service postfix start
sudo chkconfig postfix on
        ```

    1.  **For CentOS 7:**

        ```
sudo yum install postfix curl
sudo systemctl enable postfix
sudo systemctl start postfix
        ```

## Quick install

```
curl -s https://package.perforce.com/bootstrap/gitswarm.sh | sudo sh -
```

Perform the [post-installation](#post-installation) steps.

## Post-installation

1.  **Verify the external URL for your GitSwarm instance:**

    View `/etc/gitswarm/gitswarm.rb`, and verify that the following
    setting is set to the URL that your GitSwarm users should use:

    ```
external_url "http://gitswarm.example.com"
    ```

    Edit the setting if necessary.

1.  **Set the timezone for your GitSwarm instance:**

    Edit `/etc/gitswarm/gitswarm.rb`, and edit the line:

    ```
#gitlab_rails['time_zone'] = 'UTC'
    ```

    Replace `UTC` with an [appropriate
    timezone](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones), and uncomment the line.

1.  **Configure GitSwarm.**

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

If you are interested, [learn about the GitSwarm directory
structure](structure.md).

To uninstall GitSwarm, follow the [uninstall steps](uninstall.md).

###  Additional Setup Options

*   **Set up the connection to your Helix Server:**

    GitSwarm will automatically provision a Helix Server and connect Helix Git Fusion for you when you initially
    install the GitSwarm packages. ([Learn more about the provisioned server](auto_provision.md))

    In production, you will likely already have your own Helix Server already setup and will want to configure
    GitSwarm to talk to it in order to enable [project mirroring](../workflow/importing/import_from_gitfusion.md).

*   **Set up other ways of signing in:**

    Check out how to setup [LDAP](../integration/ldap.md) or [OmniAuth](../integration/omniauth.md)

### Troubleshooting

Note: For additional troubleshooting and configuration options, please see the
[Omnibus GitLab readme](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md).

*   **Install on CentOS 6 didn't seem to work, but no error output was given**

    On older versions of CentOS 6, the rpm and yum packages didn't pass each other all of the output messages, so you
    might not have seen any error messages during install. You can run `sudo yum update` or `sudo yum install yum rpm`
    to get the latest of these packages. After that, you can run `sudo yum reinstall perforce-gitswarm` to try and find
    the problem.

*   **error: "X" is an unknown key on CentOS 6**

    This error occurs during install of CentOS 6, often in a shared VM environment where some of the keys in
    `/etc/sysctl.conf` don't actually apply. The error usually looks something like this:
    ```
STDERR: error: "net.bridge.bridge-nf-call-ip6tables" is an unknown key
error: "net.bridge.bridge-nf-call-iptables" is an unknown key
error: "net.bridge.bridge-nf-call-arptables" is an unknown key
    ```

    These errors are ignorable, you just need to run `sudo gitswarm-ctl reconfigure`, and our script shouldn't
    have to modify that file again and will continue. If you want to future-proof upgrades from failing on the same
    lines, you can modify your `/etc/sysctl.conf` and comment out the keys that were listed as unknown.
