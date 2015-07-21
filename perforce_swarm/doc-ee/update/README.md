# Updating GitSwarm EE

For this first release of GitSwarm EE, no update process is currently
available.

However, if you have GitSwarm 2015.1 installed, follow these steps to
update to GitSwarm EE 2015.2:

1.  **Uninstall GitSwarm:**

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

2.  **Install GitSwarm EE:**

    Follow the [installation steps](../install/README.md)
