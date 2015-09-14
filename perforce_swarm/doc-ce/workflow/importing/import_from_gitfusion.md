## Import from Helix Git Fusion into GitSwarm

Helix Git Fusion is a Git remote repository service that uses the Helix
Versioning Engine (P4D) as its back end. Users interact with Git Fusion as
they would with any other Git remote repository.

It takes just a few steps to import your existing Git Fusion projects into
GitSwarm.

Once imported, GitSwarm keeps the Git Fusion project up to date using
bi-directional mirroring; any changes pushed to a GitSwarm project are
mirrored to Git Fusion, and changes within the Git Fusion project (even if
initiated within the Helix Versioning Engine) are mirrored into the
GitSwarm project.

Note: the mirroring capability is not currently available for existing
projects in GitSwarm. Mirroring capability for all projects should be
available in a future GitSwarm release.

### Requirements

* Helix Git Fusion 2015.2, or newer.
* Helix GitSwarm 2015.3, or newer.

### Recommendations

* Install GitSwarm and Git Fusion on separate machines to improve
  performance and scalability. (Note: GitSwarm 2015.3+ installs with a
  Git Fusion server already configured. In production, we recommend disabling
  the local Git Fusion, and using an external one. [Check out the docs on the
  auto-provisioned Git Fusion](../../install/auto_provision.md))

* Use SSH or HTTPS connections to secure mirroring connections. SSH
  connections are faster and more secure (no self-signed certificates,
  or use of OpenSSL).

### Configuration

Before you can import from Git Fusion, GitSwarm needs some configuration
that describes where the Git Fusions service(s) exist.

#### Using an HTTP(S) connection

1.  **Edit the following configuration in `/etc/gitswarm/gitswarm.rb`:**

    Under the `gitswarm['git-fusion']['enabled']` section:

    ```ruby
gitswarm['git-fusion']['default']['url']      = 'http://gitswarm@-gitfusion.host/'
gitswarm['git-fusion']['default']['password'] = '<password for "gitswarm" user>'
    ```

    Note: The user (e.g. `gitswarm`) used in the url field needs to exist in
    the Helix Versioning Engine that the Git Fusion service uses, and must
    have permission to access the repositories you wish to import from.

    Note: `default` is an example key that is used to configure the connection
    to a particular Git Fusion server. Similarly, you can include configurations
    to other Git Fusion servers under other uniquely-named keys.

    ```ruby
gitswarm['git-fusion']['default']['url']        = 'http://gitswarm@gitfusion.host/'
gitswarm['git-fusion']['default']['password']   = '<password for "gitswarm" user>'
gitswarm['git-fusion']['other']['url']          = 'http://other-user@other-gitfusin.host/'
gitswarm['git-fusion']['other']['password']     = '<password for "other-user" user>'
    ```

    Note: While we do not recommend using self-signed SSL certificates (and
    these should never be used in production), if you are using self-signed
    certificates for SSL connections in a test environment, you may want to
    specify:

    ```ruby
gitswarm['git-fusion']['other']['git_config_params'] = 'http.sslVerify=false'
    ```

1.  **Make the configuration change active:**

    ```bash
sudo gitswarm-ctl reconfigure
    ```

#### Using an SSH connection

1.  **Add the following configuration to `/etc/gitswarm/gitswarm.rb`:**

    ```ruby
gitswarm['git-fusion']['default']['url']             = 'git@gitfusion.host'
    ```

1.  **Make this configuration change active:**

    ```bash
sudo gitswarm-ctl reconfigure
    ```

To permit GitSwarm to connect to Git Fusion via SSH, follow these steps:

1.  **Log in to the GitSwarm machine**

    ```bash
ssh someuser@gitswarm.host
    ```

1.  **Start a new shell as the `git` user**

    ```bash
sudo su - git
    ```

1.  **Generate OpenSSH keys**

    `ssh-keygen` has many options for key generation. Here is an
    example:

    ```bash
ssh-keygen -t rsa -b 2048
    ```

    Note: do not generate keys with a passphrase; you do not have
    an opportunity to enter the passphrase whenever GitSwarm
    connects to Git Fusion.

1.  **Install the public key in the Git Fusion service.**

    This process involves interacting with the Helix Versioning Engine
    that the Git Fusion service connects to. The steps are
    described in the the [Git Fusion
    guide](http://www.perforce.com/perforce/doc.current/manuals/git-fusion/index.html),
    in the section [Authenticating Git Users using
    SSH](http://www.perforce.com/perforce/r15.1/manuals/git-fusion/appendix.ssh.html).

    Note: When installing the public key on the Git Fusion service,
    a system user needs to exist (we recommend `gitswarm`), and the
    public key needs to be installed in Git Fusion/p4d for that user.

1.  **Verify the SSH key works**

    Run this step from the GitSwarm server.

    ```bash
ssh git@gf_host
    ```

    Note: you should not see a password prompt. If you do, there is
    a configuration problem. The [Git Fusion
    guide](http://www.perforce.com/perforce/doc.current/manuals/git-fusion/index.html)
    has a section on [Troubleshooting SSH key
    issues](http://www.perforce.com/perforce/doc.current/manuals/git-fusion/appendix.ssh.html#section_xrm_rdw_w3).

1.  **Log out**

    Disconnect from the `gf_host`. Exit from the shell running as
    `git`.

### Importing a Git Fusion Repository

1.  Sign in to your GitSwarm instance and go to your dashboard.
1.  Click "New Project".

    ![New project page](gitfusion_importer/new_project_page.png)

1.  Click the "Helix Git Fusion Server" drop-down menu to select an available
    Git Fusion Server to import from.

1.  Click the "Repository" drop-down menu under the "Mirror an exising repository"
    option and select an available Git Fusion repository to import.

    ![Select repository to import](gitfusion_importer/choose_repo.png)

1.  Fill in the rest of the details for your project.

1.  Click "Create Project".

    While the import is underway, a progress screen is displayed:

    ![Import in progress](gitfusion_importer/import_in_progress.png)

### Known Issues

* Git Fusion, when installed on CentOS 7 or RHEL 7, does not support
  HTTP(S) authentication. This issue prevents pushing new work to a
  Git Fusion repo, including any updates in GitSwarm that would be
  mirrored to Git Fusion. Instead, use SSH connections when Git Fusion
  is hosted on CentOS/RHEL 7.

* For projects that are mirrored between GitSwarm and Git Fusion, the
  project name can only contain letters, numbers, underscores, periods,
  dashes, and spaces. Project names must begin with a letter, number,
  or underscore.

  Any projects that were originally created within the Helix Versioning
  Engine (P4D) can contain Unicode and other special characters. When
  you import a project from Git Fusion, the project name you provide to
  GitSwarm must adhere to the naming convention described above.

  If you are using multi-byte characters in any of your Git Fusion
  repository names, you should use an SSH connection to Git Fusion.

* Once a project has been created with mirroring to Git Fusion, changing
  the settings in `/etc/gitswarm/gitswarm.rb` does not update the
  mirroring settings for the project (or any other project). This can
  result in problems that prevent using the project in any way.
  Unfortunately, the solution is to delete the project, correct the
  settings in `gitswarm.rb`, and then re-create the project.

### Problems?

If you encounter problems with importing projects from Git Fusion, or with
mirroring between GitSwarm and Git Fusion, please contact
Perforce support <support@perforce.com> for assistance.
