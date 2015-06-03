# Uninstall GitSwarm

To uninstall GitSwarm, follow these steps:

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
sudo dpkg --purge perforce-gitswarm
        ```

    1.  **For CentOS/RHEL:**

        ```
sudo rpm -e perforce-gitswarm
        ```
