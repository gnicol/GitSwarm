# Installation

1.  **Check if your server meets the [hardware
    requirements](requirements.md).**
1.  **Install and configure the necessary dependencies.**

    Note: If you install Postfix to send email please select ‘Internet
    Site’ during setup. Instead of using Postfix, you can also use Sendmail
    or configure a custom SMTP server. Do not use Exim to send email from
    GitSwarm.  

    1.  **For Ubuntu:**

        ```
sudo apt-get install openssh-server
sudo apt-get install postfix
        ```

    1.  **For CentOS/RHEL:**

        ```
sudo yum install openssh-server
sudo yum install postfix
sudo yum install cronie
sudo service postfix start
sudo chkconfig postfix on
sudo lokkit -s http -s ssh
        ```
        Note: The commands above also open HTTP and SSH access in the
        system firewall.

1.  Download the GitSwarm package and install everything.

    1.  **For Debian or Ubuntu**:

        ```
wget https://preview.perforce.com/gitswarm/r15.1/gitswarm-2015.1.deb
sudo dpkg -i gitswarm-2015.1.deb
        ```

    1.  **For CentOS/RHEL 6**:

        ```
wget https://preview.perforce.com/gitswarm/r15.1/gitswarm-2015.1.el6.rpm
sudo rpm -i gitswarm-2015.1.el6.rpm
        ```

    1.  **For CentOS/RHEL 7**:

        ```
wget https://preview.perforce.com/gitswarm/r15.1/gitswarm-2015.1.el7.rpm
sudo rpm -i gitswarm-2015.1.el7.rpm
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

    Note: For troubleshooting and configuration options, please see the
    [Omnibus GitLab
    readme](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md).

1.  **Tweet about it!**

If you are interested, [learn about the GitSwarm directory
structure](structure.md).

