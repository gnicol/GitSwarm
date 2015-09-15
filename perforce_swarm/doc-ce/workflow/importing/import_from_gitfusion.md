## Import from Helix Git Fusion into GitSwarm

Helix Git Fusion is a Git remote repository service that uses the Helix
Versioning Engine (P4D) as its back end. Users interact with Git Fusion as
they would with any other Git remote repository.

It takes just a few steps to import your existing Git Fusion projects into
GitSwarm. Additionally, for brand new projects; GitSwarm can automatically 
configure a new Git Fusion repository and use it to mirror your work into 
the Helix Versioning Engine (P4D).

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
  performance and scalability. GitSwarm 2015.3+ installs with a local 
  Helix Versioning Engine and a local Git Fusion server, all pre-configured 
  to allow you to easily try out the system. In production, we recommend disabling
  the local Git Fusion, and using an external one. [Check out the docs on the
  auto-provisioned Git Fusion](../../install/auto_provision.md))

* Use SSH or HTTPS connections to secure the mirroring connections. 
  SSH connections are faster and more secure. We recommend against using 
  unencrypted HTTP connections or HTTPS with self-signed certificates. 

### Configuration

Before you can import from Git Fusion, GitSwarm needs some configuration
that describes where the Git Fusions service(s) exist.

#### Global Configuration

GitSwarm supports a special server entry called `global`, which contains
overrides for usernames, passwords, git configuration parameters, and
convention-based repository settings.

```ruby
gitswarm['git-fusion']['global']['user']      = 'global-user'
gitswarm['git-fusion']['global']['password']  = '<password for "global-user" user>'
gitswarm['git-fusion']['default']['url']      = 'http://gitswarm@gitfusion.host/'
gitswarm['git-fusion']['default']['password'] = '<password for "gitswarm" user>'
gitswarm['git-fusion']['development']['url']  = 'http://dev-gitfusion.host/'
gitswarm['git-fusion']['production']['url']   = 'http://prod-gitfusion.host/'
```

In the above example, the user `global-user` will be used to log in to the `development`
and `production` Git Fusion servers. The user for the `default` Git Fusion server
will remain as `gitswarm`.

Note: Only `user`, `password`, `git_config_params`, `perforce['user']`,
`perforce['password']` and `auto_create` settings can have global defaults.
Global settings for `url` and `perforce['port']` will be ignored if present.

Note: The following priority is given to user/password lookups:
1. Entry-specific user/password keys
1. User/password specified on the Git Fusion server `url`
1. Global user/password
1. Default (`gitswarm` for user, `''` for password)

#### Using an HTTP(S) connection

1.  **Edit the following configuration in `/etc/gitswarm/gitswarm.rb`:**

    After the `gitswarm['git-fusion']['enabled']` section:

    ```ruby
gitswarm['git-fusion']['enabled']              = true
gitswarm['git-fusion']['my_entry']['url']      = 'http://gitswarm@gitfusion.host/'
gitswarm['git-fusion']['my_entry']['password'] = '<password for "gitswarm" user>'
    ```

    Note: The user (e.g. `gitswarm`) needs to exist in the Helix Versioning Engine
    that the Git Fusion service uses, and must have permission to access
    the repositories you wish to import from.

    Note: `my_entry` is an example key that is used to configure the connection
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
    certificates for HTTPS connections in a test environment, you will need to
    specify:

    ```ruby
gitswarm['git-fusion']['my_entry']['git_config_params'] = 'http.sslVerify=false'
    ```
    
    Note: the key 'my_entry' can be replaced with a unique value of your choosing.

1.  **Make the configuration change active:**

    ```bash
sudo gitswarm-ctl reconfigure
    ```

#### Using an SSH connection

1.  **Add the following configuration to `/etc/gitswarm/gitswarm.rb`:**

    ```ruby
gitswarm['git-fusion']['enabled']                       = true
gitswarm['git-fusion']['my_entry']['url']               = 'git@gitfusion.host'
gitswarm['git-fusion']['my_entry']['password']          = '<password for "gitswarm" user>'
    ```

1.  **Make this configuration change active:**

    ```bash
sudo gitswarm-ctl reconfigure
    ```

To permit GitSwarm to connect to Git Fusion via SSH, follow these steps:

1.  **Get a copy of the `git` user's public SSH key**

    ```bash
sudo cat ~git/.ssh/id_rsa.pub
    ```

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

#### Convention-based Repository Configuration

In order for GitSwarm to automatically create new Git Fusion 
repositories when adding projects, GitSwarm needs to connect
to the Helix Versioning Engine (P4D) directly. GitSwam also
needs to be configure with a path where it can place the repositories
files.

At a minimum, GitSwarm needs to be configured with a user id and
password for the connection. When using HTTP(S) this information 
will already be present. When using SSH, you may need to add the
settings:

```ruby
gitswarm['git-fusion']['enabled']                       = true
gitswarm['git-fusion']['my_entry']['url']               = 'git@gitfusion.host'
gitswarm['git-fusion']['my_entry']['user']              = '<perforce-user-id>'
gitswarm['git-fusion']['my_entry']['password']          = '<password for "gitswarm" user>'
```

Note: If no `port` is specified under the `perforce` key, GitSwarm
will connect to the given Git Fusion instance and use the same
port as Git Fusion (the `my_entry` Git Fusion instance in the above example).

If the auto-detected Perforce Port is incorrect, you may optionally 
specify the appropriate value manually by setting:

```ruby
gitswarm['git-fusion']['my_entry']['perforce']['port']  = 'ssl:my-fusion:1666'
```

Note: GitSwarm will use the following priority for determining user/password
to connect to Perforce:
1. Entry-specific user/password keys
1. User/password specified on the Git Fusion server `url`
1. Global user/password
1. Default (`gitswarm` for user, `''` for password)

Note: The user (e.g. `gitswarm`) needs to exist in the Helix Versioning Engine 
that the Git Fusion service uses, and must have permission to access the 
repositories you wish to import from.

Note: The `my_entry` key is used to assign config values to a particular
git-fusion instance. You can include more configured servers under other
keys.

GitSwarm generates a Git Fusion configuration and unique depot path
for each new project that has convention-based mirroring enabled. It
constructs these by substituting the GitSwarm project's namespace and
project path into a template that is specified in the configuration.

```ruby
 gitswarm['git-fusion']['global']['auto_create']['path_template']      = '//gitswarm/projects/{namespace}/{project-path}'
 gitswarm['git-fusion']['global']['auto_create']['repo_name_template'] = 'gitswarm-{namespace}-{project-path}'
```

Note: `{namespace}` and `{project-path}` are substituted for the
GitSwarm project's namespace and project path (name) when the
project is created.

Note: The depot specified in the `path_template` ('gitswarm'
in the above example) must exist *prior* to attempting to
use the convention-based repository feature. GitSwarm does
*not* create this depot for you.

### New GitSwarm Project with Convention-based Mirroring

1.  Sign in to your GitSwarm instance and go to your dashboard.
1.  Click "New Project".

    ![New project page](gitfusion_importer/new_project_page.png)

1.  Click the "Git Fusion Server" drop-down menu to select an available
    Git Fusion Server that your project will be mirrored to.

1.  Click the 'Create a Helix GitSwarm project to mirror'

    ![Select repository to import](gitfusion_importer/choose_auto_create.png)

1.  Fill in the rest of the details for your project.

1.  Click "Create Project".

    While the import is underway, a progress screen is displayed:

    ![Import in progress](gitfusion_importer/import_in_progress.png)

### Importing a Git Fusion Repository

1.  Sign in to your GitSwarm instance and go to your dashboard.
1.  Click "New Project".

    ![New project page](gitfusion_importer/new_project_page.png)

1.  Click the "Helix Git Fusion Server" drop-down menu to select an available
    Git Fusion Server to import from.

1.  Click the "Repository" drop-down menu under the "Mirror an existing repository"
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

* GitSwarm project names can only contain letters, numbers, underscores,
  periods, and dashes, and must begin with a letter, number,
  or underscore.

  Since depot paths in the Helix Versioning Engine (P4D) can contain
  Unicode and other special characters, we recommend depot paths for
  projects you intend on importing into GitSwarm via Git Fusion adhere to
  the naming convention described above.

  If you are using multi-byte characters in any of your Git Fusion
  repository names, you should use an SSH connection to Git Fusion.

* If a new project is created and GitSwarm is used to automatically mirror
  it (via convention-based mirroring), updating the project's namespace
  and/or project name will *not* change the location under Helix
  Versioning Engine (P4D). In order to move the project's files to a
  new location you will need to delete the project, re-create it with
  convention-based mirroring, and then re-add the files.

* Once a project has been created with mirroring to Git Fusion, changing
  the settings in `/etc/gitswarm/gitswarm.rb` does not update the
  mirroring settings for the project (or any other project). This can
  result in problems that prevent pushing new changes to the project.
  Unfortunately, the solution is to delete the project, correct the
  settings in `gitswarm.rb`, and then re-create the project.

### Problems?

If you encounter problems with importing projects from Git Fusion, or with
mirroring between GitSwarm and Git Fusion, please contact
Perforce support <support@perforce.com> for assistance.