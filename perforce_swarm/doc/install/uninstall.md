# Uninstall GitSwarm

To uninstall GitSwarm, follow these steps:

1.  **Optional:** Remove all GitSwarm data.

    ```
sudo gitswarm-ctl cleanse
    ```

1.  **Optional:** Remove all GitSwarm users and groups.

    ```
sudo gitswarm-ctl remove_users
    ```

1.  **Stop GitSwarm and remove its supervisory processes.**

    ```
sudo gitswarm-ctl uninstall
    ```

1.  **Uninstall the GitSwarm package.**

    1.  **For Debian or Ubuntu**:

        ```
sudo dpkg --purge perforce-gitswarm
        ```

    1.  **For CentOS/RHEL 6/7**:

        ```
sudo rpm -e perforce-gitswarm
        ```
