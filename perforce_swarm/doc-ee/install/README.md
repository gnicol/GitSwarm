# Installation

1.  **Check if your server meets the [hardware
    requirements](requirements.md).**

1.  **Install and configure the necessary dependencies.**

    Note: If you install Postfix to send email, please select
    `Internet Site` during setup. Instead of using Postfix, you can also
    use Sendmail or configure a custom SMTP server. Do not use Exim to send
    email from GitSwarm EE.

    We advise installing GitSwarm EE on a fully up-to-date operating system.
    We've included the system specific upgrade commands below.

    1.  **For Ubuntu 12.04:**

        1.  Add Perforce's packaging key to your APT keyring

            ```
wget -q https://package.perforce.com/perforce.pubkey -O - | sudo apt-key add -
            ```

        1.  Add Perforce's repository to your apt configuration

            Create a file called `/etc/apt/sources.list.d/perforce.sources.list` with the following line:
            ```
deb https://package.perforce.com/apt/ubuntu precise release
            ```

        1.  Install dependencies

            ```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install curl openssh-server ca-certificates postfix perforce-server helix-git-fusion-base
            ```

    1.  **For Ubuntu 14.04:**

        1.  Add Perforce's packaging key to your APT keyring

            ```
wget -q https://package.perforce.com/perforce.pubkey -O - | sudo apt-key add -
            ```

        1.  Add Perforce's repository to your apt configuration

            Create a file called `/etc/apt/sources.list.d/perforce.sources.list` with the following line:
            ```
deb https://package.perforce.com/apt/ubuntu trusty release
            ```

        1.  Install dependencies

            ```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install curl openssh-server ca-certificates postfix perforce-server helix-git-fusion-base
            ```

    1.  **For CentOS/RHEL 6:**

        1. Add Perforce's packaging key to your RPM keyring

            ```
sudo rpm --import https://package.perforce.com/perforce.pubkey
            ```

        1. Add Perforce's yum repository to your configuration

            Create a file called `/etc/yum.repos.d/perforce.repo` with the  following content:
            ```
[perforce]
name=Perforce
baseurl=https://package.perforce.com/yum/rhel/6/x86_64
enabled=1
gpgcheck=1
            ```

        1.  Install dependencies and configure firewall

            ```
sudo yum update
sudo yum install curl openssh-server postfix
sudo service postfix start
sudo chkconfig postfix on
sudo lokkit -s http -s ssh
            ```
        Note: The commands above also open HTTP and SSH access in the
        system firewall.

    1.  **For CentOS/RHEL 7:**

        1. Add Perforce's packaging key to your RPM keyring

            ```
sudo rpm --import https://package.perforce.com/perforce.pubkey
            ```

        1. Add Perforce's yum repository to your configuration

            Create a file called `/etc/yum.repos.d/perforce.repo` with the  following content:
            ```
[perforce]
name=Perforce
baseurl=https://package.perforce.com/yum/rhel/7/x86_64
enabled=1
gpgcheck=1
            ```

        1.  Install dependencies and configure firewall
        ```
sudo yum update
sudo yum install curl openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
sudo firewall-cmd --permanent --add-service=http
sudo systemctl reload firewalld
        ```
        Note: The commands above also open HTTP and SSH access in the
        system firewall.

1.  **Download the GitSwarm EE package and install everything.**

    1.  **For Ubuntu 12.04:**

        ```
curl -O http://preview.perforce.com/gitswarm/perforce-gitswarm-ee-2015.4.precise.amd64.deb
sudo dpkg -i perforce-gitswarm-ee-2015.4.precise.amd64.deb
        ```

    1.  **For Ubuntu 14.04:**

        ```
curl -O http://preview.perforce.com/gitswarm/perforce-gitswarm-ee-2015.4.trusty.amd64.deb
sudo dpkg -i perforce-gitswarm-ee-2015.4.trusty.amd64.deb
        ```

    1.  **For CentOS/RHEL 6:**

        ```
curl -O http://preview.perforce.com/gitswarm/perforce-gitswarm-ee-2015.4.el6.x86_64.rpm
sudo yum install perforce-gitswarm-ee-2015.4.el6.x86_64.rpm
        ```

    1.  **For CentOS/RHEL 7:**

        ```
curl -O http://preview.perforce.com/gitswarm/perforce-gitswarm-ee-2015.4.el7.x86_64.rpm
sudo yum install perforce-gitswarm-ee-2015.4.el7.x86_64.rpm
        ```

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

1.  **Configure and start GitSwarm EE.**

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

    GitSwarm EE will automatically provision a Helix Server and connect Helix Git Fusion for you when you initially
    install the GitSwarm EE packages. ([Learn more about the provisioned server](auto_provision.md))

    In production, you will likely already have your own Helix Server already setup and will want to configure
    GitSwarm EE to talk to it in order to enable [project mirroring](../workflow/importing/import_from_gitfusion.md).

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

