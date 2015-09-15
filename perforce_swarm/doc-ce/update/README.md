# Updating GitSwarm to 2015.3

1.  **Download the 2015.3 GitSwarm package and install it.**


    ```
curl https://package.perforce.com/bootstrap/gitswarm.sh | sudo sh -s -
    ```

    The script should add the Perforce package repository, and install the latest
    version of GitSwarm. Before install we run a backup on the existing GitSwarm.

1.  **Check the application status.**

    Check if GitSwarm and its environment are configured correctly:
    ```
sudo gitswarm-rake gitswarm:check
    ```

# New configuration options

*  **Allow new repo creation in Helix Git Fusion Servers**

    You can configure where in the Helix Versioning Engine (P4D) you want new project to store their repos. See the
    [Convention-based Repository Configuration instructions](../workflow/importing/import_from_gitfusion.md).

*  **Discovering new config options**

    GitSwarm doesn't update your `/etc/gitswarm/gitswarm.rb` for you, but we do include an updated example template:
    `/etc/gitswarm/gitswarm.rbe`. You can see what sort of config options have been changed since last release by running
    ```
sudo diff /etc/gitswarm/gitswarm.rb /etc/gitswarm/gitswarm.rbe
    ```

# For users upgrading FROM 2015.1

## Post-upgrade steps

1.  **Create `gitswarm` user:**

    Before you can [import projects from Git
    Fusion](../workflow/importing/import_from_gitfusion.md), you need to
    manually create the `gitswarm` user within GitSwarm.
