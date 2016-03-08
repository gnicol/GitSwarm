# Uninstall GitSwarm

To uninstall GitSwarm, follow these steps:

1. Optional: **Remove GitSwarm data.**

    If you want to **completely remove** all GitSwarm data, run:

    ```
sudo gitswarm-ctl cleanse
    ```

    > **Warning: this permanently removes all GitSwarm-related data.**

1. **Uninstall GitSwarm's supervisory processes.**

    ```
sudo gitswarm-ctl uninstall
    ```

1.  **Uninstall the GitSwarm package.**

    1.  **For uninstalling pre-15.4 versions:**

        1.  **For Ubuntu:**

            ```
sudo apt-get purge perforce-gitswarm
            ```

        1.  **For CentOS/RHEL:**

            ```
sudo yum remove perforce-gitswarm
            ```

    1.  **For uninstalling >=15.4 versions:**

        1.  **For Ubuntu:**

            ```
sudo apt-get purge helix-gitswarm
            ```

        1.  **For CentOS/RHEL:**

            ```
sudo yum remove helix-gitswarm
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
