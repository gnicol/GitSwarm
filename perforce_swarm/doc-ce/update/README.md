# Updating GitSwarm from 2015.1 to 2015.2

1.  **Download the 2015.2 GitSwarm package and install it.**

    1.  **For Ubuntu 12.04:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.2/bin.ubuntu12x86_64/perforce-gitswarm-2015.2.precise.amd64.deb
sudo dpkg -i perforce-gitswarm-2015.2.precise.amd64.deb
        ```

    1.  **For Ubuntu 14.04:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.2/bin.ubuntu14x86_64/perforce-gitswarm-2015.2.trusty.amd64.deb
sudo dpkg -i perforce-gitswarm-2015.2.trusty.amd64.deb
        ```

    1.  **For CentOS/RHEL 6:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.2/bin.centos6x86_64/perforce-gitswarm-2015.2.el6.x86_64.rpm
sudo rpm -U perforce-gitswarm-2015.2.el6.x86_64.rpm
        ```

    1.  **For CentOS/RHEL 7:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.2/bin.centos7x86_64/perforce-gitswarm-2015.2.el7.x86_64.rpm
sudo rpm -U perforce-gitswarm-2015.2.el7.x86_64.rpm
        ```

## Post-upgrade steps

1.  **Create `gitswarm` user:**

    Before you can [import projects from Git
    Fusion](../workflow/importing/import_from_gitfusion.md), you need to
    manually create the `gitswarm` user within GitSwarm.
