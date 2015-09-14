# Uninstall GitSwarm

To uninstall GitSwarm, follow these steps:

1.  **Stop the Helix Server if it is running**

    Check the status:
    ```
sudo p4dctl status gitswarm
    ```
    If running, shut it down, and backup the configuration.
    ```
sudo p4dctl stop gitswarm
sudo mv /etc/perforce/p4dctl.conf.d/gitswarm.conf ~/gitswarm.conf.backup
    ```

1.  **Optional:** Remove all GitSwarm data.

    ```
sudo gitswarm-ctl cleanse
    ```

1.  **Stop GitSwarm and remove its supervisory processes.**

    ```
sudo gitswarm-ctl uninstall
    ```

1.  **Uninstall the GitSwarm package.**

    1.  **For Ubuntu:**

        ```
sudo apt-get purge perforce-gitswarm
        ```

    1.  **For CentOS/RHEL:**

        ```
sudo yum remove perforce-gitswarm
        ```

1.  **Optional:**, Remove dependencies

    1.  **For Ubuntu:**

        ```
sudo apt-get autoremove
        ```

    1.  **For CentOS/RHEL:**

        ```
sudo yum remove perforce-cli-base perforce-server-base helix-git-fusion-base
        ```
