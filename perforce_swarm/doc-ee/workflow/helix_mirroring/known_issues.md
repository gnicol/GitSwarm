[Help](../../README.md)
/ [Workflow](../README.md)
/ [Helix Mirroring](README.md)
/ Known issues

## Known issues

*   Helix Mirroring stops working when a GitSwarm EE project involves
    commits that contain only tags and no file changes.

*   GitSwarm EE allows you to merge task branches using fast-forward
    merges. Behind the scenes, this involves rebasing and forced pushes.
    Helix Mirroring is incompatible with these operations, and so the
    "Fast-forward merge" and "Merge commit with semi-linear history"
    options on your GitSwarm EE project pages do not work.

*   GitSwarm EE project names can only contain letters, numbers,
    underscores, periods, and dashes, and must begin with a letter, number,
    or underscore.

    Since depot paths in the Helix Versioning Engine (P4D) can contain
    Unicode and other special characters, we recommend depot paths for
    projects you intend on importing into GitSwarm EE via Git Fusion adhere
    to the naming convention described above.

    If you are using multi-byte characters in any of your Git Fusion
    repository names, you should use an SSH connection to Git Fusion.

*   If a new project is created and GitSwarm EE is used to automatically
    mirror it (via convention-based mirroring), updating the project's
    namespace and/or project name does *not* change the location under
    Helix Versioning Engine (P4D). In order to move the project's files to
    a new location, you need to delete the project, re-create it with
    convention-based mirroring, and then re-add the files.

*   Once a project has been created with mirroring to Git Fusion, changing
    the settings in `/etc/gitswarm/gitswarm.rb` does not update the
    mirroring settings for the project (or any other project). This can
    result in problems that prevent pushing new changes to the project.
    Unfortunately, the solution is to delete the project, correct the
    settings in `gitswarm.rb`, and then re-create the project.

*   Git Fusion, when installed on CentOS/RHEL 7.x, does not support HTTP(S)
    authentication. This issue prevents pushing new work to a Git Fusion
    repo, including any updates in GitSwarm EE that would be mirrored to
    Git Fusion. Instead, use SSH connections when Git Fusion is hosted on
    CentOS/RHEL 7.x.

*   The following error can be displayed when Git Swarm is attempting to
    connect to a remote Helix Git Fusion server (running on Centos/RHEL
    6.6+) over SSH, as part of mirroring setup on the `Create Project`
    page.

    ```
    Git Fusion Server:
    There was an error communicating with Git Fusion:
    Using 'ascii' file encoding will ultimately result in errors, please set LANG/LC_ALL to 'utf-8' in environment configuration.
    ```

    You can work around this error by doing the following steps:

    1.  Connect (SSH) to the remote Helix Git Fusion server as a user with
        sudo access.

    1.  Determine the default LANG setting for the server.

        You can do this by running the command `locale`. It should be
        something like ```en_US.UTF-8```. If the system locale is not a
        UTF8 locale, please contact <support@perforce.com> for help on how
        to proceed.

    1.  Determine the Git Fusion OS user. This user is normally `git`, but
        may be different.

        The username should be in your `/etc/gitswarm/gitswarm.rb` file
        under the `[git-fusion][xxx][url]` setting. It should be in the
        format `username@hostname`.

    1.  Using sudo access and an editor of your choice, edit the .bashrc
        file of the Git Fusion OS user.

        You can find this file using the path `~username/.bashrc`
        (replacing username with the Git Fusion OS user).

        Add a line into the `.bashrc` file exporting the LANG setting you
        determined earlier. e.g. ```export LANG=en_US.UTF-8```

    1.  Save the file.

    1.  Refresh the `Create Project` page in GitSwarm EE. The error should
        be resolved.

## Problems?

If you encounter problems with importing projects from Git Fusion, or with
Helix Mirroring between GitSwarm EE and Git Fusion, please contact
Perforce support <support@perforce.com> for assistance.
