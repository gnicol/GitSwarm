# Installation

1.  **Check if your server meets the [hardware
    requirements](requirements.md).**

1.  **Install and configure the necessary dependencies.**

    Note: If you install Postfix to send email, please select
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

1.  **Download the GitSwarm package and install everything.**

    1.  **For Ubuntu 12.04:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.1/bin.ubuntu12x86_64/perforce-gitswarm-2015.1.precise.amd64.deb
sudo dpkg -i perforce-gitswarm-2015.1.precise.amd64.deb
        ```

    1.  **For Ubuntu 14.04:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.1/bin.ubuntu12x86_64/perforce-gitswarm-2015.1.trusty.amd64.deb
sudo dpkg -i perforce-gitswarm-2015.1.trusty.amd64.deb
        ```

    1.  **For CentOS/RHEL 6:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.1/bin.centos6x86_64/perforce-gitswarm-2015.1.el6.x86_64.rpm
sudo rpm -i perforce-gitswarm-2015.1.el6.x86_64.rpm
        ```

    1.  **For CentOS/RHEL 7:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.1/bin.centos6x86_64/perforce-gitswarm-2015.1.el7.x86_64.rpm
sudo rpm -i perforce-gitswarm-2015.1.el7.x86_64.rpm
        ```

1.  **Verify the external URL for your GitSwarm instance:**

    View `/etc/gitswarm/gitswarm.rb`, and verify that the following
    setting:

    ```
external_url "http://gitswarm.example.com"
    ```

    is set to the URL that your GitSwarm users should use. Edit the setting
    if necessary.

1.  **Set the timezone for your GitSwarm instance:**

    Edit `/etc/gitswarm/gitswarm.rb`, and edit the line:

    ```
#gitlab_rails['time_zone'] = 'UTC'
    ```

    Replace `UTC` with an [appropriate
    timezone](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones), and uncomment the line.

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
