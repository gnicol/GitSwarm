# Manual installation steps (package manager)

1.  **Follow the [pre-installation steps](README.md) first.**

1.  **Add Perforce's repository to your package configuration.**

    See [this document](https://www.perforce.com/perforce-packages) for
    instructions on adding Perforce's packaging key to your keyring, as well
    as adding the Perforce package repository to your package configuration.

1.  **Install the GitSwarm package and necessary dependencies via the OS
    package manager.**
    1.  **For Ubuntu (12.04 and 14.04):**

        ```
sudo apt-get install helix-gitswarm
        ```
    1.  **For CentOS (6 and 7):**

        ```
sudo yum install helix-gitswarm
        ```

1.  **Complete the post-installation steps.**

    [Post-installation](README.md#post-installation) steps.

# Manual installation steps (offline install, without package manager)

1.  **Follow the [pre-installation steps](README.md) first.**

1.  **Add Perforce's repository to your package configuration.**

    See [this document](https://www.perforce.com/perforce-packages) for
    instructions on adding Perforce's packaging key to your keyring, as well
    as adding the Perforce package repository to your package configuration.

1.  **Install and configure the necessary dependencies.**

    1.  **For Ubuntu (12.04 and 14.04):**

        ```
sudo apt-get install openssh-server ca-certificates helix-p4d helix-git-fusion-base
        ```

1.  **Download the GitSwarm package and install everything.**

    1.  **For Ubuntu 12.04:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.4/bin.ubuntu12x86_64/helix-gitswarm-2015.4.precise.amd64.deb
sudo dpkg -i helix-gitswarm-2015.4.precise.amd64.deb
        ```

    1.  **For Ubuntu 14.04:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.4/bin.ubuntu14x86_64/helix-gitswarm-2015.4.trusty.amd64.deb
sudo dpkg -i helix-gitswarm-2015.4.trusty.amd64.deb
        ```

    1.  **For CentOS 6:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.4/bin.centos6x86_64/helix-gitswarm-2015.4.el6.x86_64.rpm
sudo yum install perforce-gitswarm-2015.4.el6.x86_64.rpm
        ```

    1.  **For CentOS 7:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.4/bin.centos7x86_64/helix-gitswarm-2015.4.el7.x86_64.rpm
sudo yum install perforce-gitswarm-2015.4.el7.x86_64.rpm
        ```

1.  **Complete the post-installation steps.**

    [Post-installation](README.md#post-installation) steps.
