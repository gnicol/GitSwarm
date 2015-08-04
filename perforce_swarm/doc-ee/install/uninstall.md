# Uninstall GitSwarm EE

To uninstall GitSwarm EE, follow these steps:

1.  **Optional:** Remove all GitSwarm EE data.

    ```
sudo gitswarm-ctl cleanse
    ```

1.  **Stop GitSwarm EE and remove its supervisory processes.**

    ```
sudo gitswarm-ctl uninstall
    ```

1.  **Uninstall the GitSwarm EE package.**

    1.  **For Ubuntu:**

        ```
sudo dpkg --purge perforce-gitswarm-ee
        ```

    1.  **For CentOS/RHEL:**

        ```
sudo rpm -e perforce-gitswarm-ee
        ```
