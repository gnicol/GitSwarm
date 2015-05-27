# Installation

1.  **Check if your server meets the [hardware
    requirements](requirements.md).**
1.  **Install and configure the necessary dependencies.**

    Note: If you install Postfix to send email please select
    `Internet Site` during setup. Instead of using Postfix, you can also
    use Sendmail or configure a custom SMTP server. Do not use Exim to send
    email from GitSwarm.

    1.  **For Ubuntu:**

        ```
sudo apt-get install curl openssh-server ca-certificates postfix
        ```

    1.  **For CentOS/RHEL 6:**

        ```
sudo yum install curl openssh-server postfix cronie
sudo service postfix start
sudo chkconfig postfix on
sudo lokkit -s http -s ssh
        ```
        Note: The commands above also open HTTP and SSH access in the
        system firewall.

    1.  **For CentOS/RHEL 7:**

        ```
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

1.  **Configure the Perforce package repository.**

    As `root`, run one of the following:

    1.  **For Ubuntu:**

        Create the file `/etc/apt/sources.list.d/perforce.list` with
        the following content:

        ```
deb http://package.perforce.com/apt/ubuntu/ precise release
        ```

    1.  **For CentOS/RHEL:**

        Create the file `/etc/yum.repos.d/perforce.repo` with the
        following content:

        ```
[Perforce]
name=Perforce
baseurl=http://package.perforce.com/yum/rhel/6/x86_64/
enabled=1
gpgcheck=1
        ```

1.  **Import the Perforce package signing key.**

    1.  **For Ubuntu:**

        ```
$ wget -qO - http://package.perforce.com/perforce.pubkey | sudo apt-key add
$ sudo apt-get update
        ```

    1.  **For CentOS/RHEL (run this command as root):**

        ```
# rpm --import http://package.perforce.com/perforce.pubkey
        ```

    For information about how to verify the authenticity of the signing
    key, see:

    http://answers.perforce.com/articles/KB_Article/Public-Key-for-Installation-Packages

1.  **Download the GitSwarm package and install everything.**

    1.  **For Ubuntu:**

        ```
$ sudo apt-get install perforce-gitswarm
        ```

    1.  **For CentOS/RHEL: (run this command as root)**

        ```
# yum install perforce-gitswarm
        ```

1.  **Configure and start GitSwarm.**

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

Note: For troubleshooting and configuration options, please see the
[Omnibus GitLab
readme](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md).
