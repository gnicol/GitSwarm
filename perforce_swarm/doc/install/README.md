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

    1.  **For CentOS/RHEL 6:**

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

    1.  **For CentOS/RHEL 7:**

        ```
sudo yum install openssh-server
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

1.  Download the GitSwarm package and install everything.

    1.  **For Ubuntu 12.x**:

        ```
wget http://preview.perforce.com/gitswarm/perforce-gitswarm_2015.1.beta.ub12.amd64.deb
sudo dpkg -i perforce-gitswarm_2015.1.beta.ub12.amd64.deb
        ```

    1.  **For Ubuntu 14.x**:

        ```
wget http://preview.perforce.com/gitswarm/perforce-gitswarm_2015.1.beta.ub14.amd64.deb
sudo dpkg -i perforce-gitswarm_2015.1.beta.ub14.amd64.deb
        ```

    1.  **For CentOS/RHEL 6**:

        ```
wget http://preview.perforce.com/gitswarm/perforce-gitswarm_2015.1.beta.el6.x86_64.rpm
sudo rpm -i perforce-gitswarm_2015.1.beta.el6.x86_64.rpm
        ```

    1.  **For CentOS/RHEL 7**:

        ```
wget http://preview.perforce.com/gitswarm/perforce-gitswarm_2015.1.beta.el7.x86_64.rpm
sudo rpm -i perforce-gitswarm_2015.1.beta.el7.x86_64.rpm
        ```

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
