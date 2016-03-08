# Uninstall GitSwarm EE

To uninstall GitSwarm EE, follow these steps:

1. Optional: **Remove GitSwarm EE data.**

    If you want to **completely remove** all GitSwarm EE data, run:

    ```
sudo gitswarm-ctl cleanse
    ```

    > **Warning: this permanently removes all GitSwarm EE-related data.**

1. **Uninstall GitSwarm EE's supervisory processes.**

    ```
sudo gitswarm-ctl uninstall
    ```

1.  **Uninstall the GitSwarm EE package.**

    1.  **For uninstalling pre-15.4 versions:**

        1.  **For Ubuntu:**

            ```
sudo apt-get purge perforce-gitswarm-ee
            ```

        1.  **For CentOS/RHEL:**

            ```
sudo yum remove perforce-gitswarm-ee
            ```

    1.  **For uninstalling >=15.4 versions:**

        1.  **For Ubuntu:**

            ```
sudo apt-get purge helix-gitswarm-ee
            ```

        1.  **For CentOS/RHEL:**

            ```
sudo yum remove helix-gitswarm-ee
            ```

1.  Optional: **Remove dependencies.**

    1. **For uninstalling pre-15.4 versions:**

         1. **For Ubuntu:**

            ```
sudo yum remove perforce-cli-base perforce-server-base helix-git-fusion-base
            ```
         1. **For CentOS/RHEL:**

            ```
sudo yum remove perforce-cli-base perforce-server-base helix-git-fusion-base
            ```
    1.  **For uninstalling >=15.4 versions:**

         1.  **For Ubuntu:**

            ```
sudo yum remove helix-cli-base helix-p4d-base helix-git-fusion-base
            ```

         1.  **For CentOS/RHEL:**

            ```
sudo yum remove helix-cli-base helix-p4d-base helix-git-fusion-base
            ```
