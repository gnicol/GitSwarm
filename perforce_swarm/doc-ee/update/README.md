# Updating GitSwarm EE to 2015.4

1.  **Download the 2015.4 GitSwarm EE package and install it.**

    Following the [installation steps](../install/README.md) for 2015.4 will
    upgrade your previous version to 2015.4. It includes adding the Perforce
    package repository to your package manager, and installing the new
    dependencies.

1.  **Check the application status.**

    Check if GitSwarm EE and its environment are configured correctly:
    ```
sudo gitswarm-rake gitswarm:check
    ```

# New configuration options

*  **Discovering new config options**

    GitSwarm EE doesn't update your `/etc/gitswarm/gitswarm.rb` for you, but we
    do include an updated example template:
    `/opt/gitswarm/etc/gitswarm.rb.template`. You can see what sort of config
    options have been changed since last release by running
    ```
sudo diff /etc/gitswarm/gitswarm.rb /opt/gitswarm/etc/gitswarm.rb.template
    ```
