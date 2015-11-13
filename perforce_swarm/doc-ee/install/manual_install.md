# Manual installation steps

1.  **Follow the [pre-installation steps](README.md) first.**

1.  **Add Perforce's packaging key to a local keyring.**

    1.  **For Ubuntu (12.04 and 14.04):**

        ```
wget -q https://package.perforce.com/perforce.pubkey -O - | sudo apt-key add -
        ```

    1.  **For CentOS (6 and 7):**

        ```
sudo rpm --import https://package.perforce.com/perforce.pubkey
        ```

1.  **Add Perforce's repository to your package configuration.**

    1.  **For Ubuntu (12.04 and 14.04):**

        Create a file called `/etc/apt/sources.list.d/perforce.sources.list`
        with the following line:

        ```
deb http://package.perforce.com/apt/ubuntu {distro} release
        ```

        Where `{distro}` is replaced with either `precise` (for 12.04), or
        `trusty` (for 14.04).

    1.  **For CentOS (6 and 7):**

        Create a file called `/etc/yum.repos.d/perforce.repo` with the
        following content:

        ```
[perforce]
name=Perforce
baseurl=http://package.perforce.com/yum/rhel/{version}/x86_64
enabled=1
gpgcheck=1
        ```

        Where `{version}` is either `6` or `7` (matching the CentOS version
        in use).

1.  **Install and configure the necessary dependencies.**

    1.  **For Ubuntu (12.04 and 14.04):**

        ```
sudo apt-get update
sudo apt-get install openssh-server ca-certificates perforce-server helix-git-fusion-base
        ```

    1.  **For CentOS/RHEL 6:**

        ```
sudo yum update
sudo yum install openssh-server
        ```

    1.  **For CentOS/RHEL 7:**

        ```
sudo yum update
sudo yum install openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
        ```

1.  **Download the GitSwarm EE package and install everything.**

    1.  **For Ubuntu 12.04:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.4/bin.ubuntu12x86_64/perforce-gitswarm-ee-2015.4.precise.amd64.deb
sudo dpkg -i helix-gitswarm-ee-2015.4.precise.amd64.deb
        ```

    1.  **For Ubuntu 14.04:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.4/bin.ubuntu14x86_64/perforce-gitswarm-ee-2015.4.trusty.amd64.deb
sudo dpkg -i helix-gitswarm-ee-2015.4.trusty.amd64.deb
        ```

    1.  **For CentOS/RHEL 6:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.4/bin.centos6x86_64/perforce-gitswarm-ee-2015.4.el6.x86_64.rpm
sudo yum install perforce-gitswarm-ee-2015.4.el6.x86_64.rpm
        ```

    1.  **For CentOS/RHEL 7:**

        ```
curl -O ftp://ftp.perforce.com/perforce/r15.4/bin.centos7x86_64/perforce-gitswarm-ee-2015.4.el7.x86_64.rpm
sudo yum install perforce-gitswarm-ee-2015.4.el7.x86_64.rpm
        ```

1.  **Complete the post-installation steps.**

    [Post-installation](README.md#post-installation) steps.
