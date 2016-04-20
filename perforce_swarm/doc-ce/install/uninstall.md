# Uninstall $GitSwarm$

To uninstall $GitSwarm$, follow these steps:

1.  Optional: **Remove $GitSwarm$ data.**

    If you want to **completely remove** all $GitSwarm$ data, run:

    ```bash
    sudo gitswarm-ctl cleanse
    ```

    > **Warning: this permanently removes all $GitSwarm$ related data.**

1.  **Uninstall $GitSwarm$'s supervisory processes.**

    ```bash
    sudo gitswarm-ctl uninstall
    ```

1.  **Uninstall the $GitSwarm$ package.**

    1.  **For uninstalling 2015.3, or earlier:**

        1.  **For Ubuntu:**

            ```bash
            sudo apt-get purge perforce-$GitSwarmPackage$
            ```

        1.  **For CentOS/RHEL:**

            ```bash
            sudo yum remove perforce-$GitSwarmPackage$
            ```

    1.  **For uninstalling 2015.4, or later:**

        1.  **For Ubuntu:**

            ```bash
            sudo apt-get purge helix-$GitSwarmPackage$
            ```

        1.  **For CentOS/RHEL:**

            ```bash
            sudo yum remove helix-$GitSwarmPackage$
            ```

1.  Optional: **Remove dependencies.**

    1.  **For uninstalling 2015.3, or earlier:**

        1.  **For Ubuntu:**

            ```bash
            sudo apt-get remove perforce-cli-base perforce-server-base helix-git-fusion-base
            ```
         1. **For CentOS/RHEL:**

            ```bash
            sudo yum remove perforce-cli-base perforce-server-base helix-git-fusion-base
            ```

    1.  **For uninstalling 2015.4, or later:**

        1.  **For Ubuntu:**

            ```bash
            sudo apt-get remove helix-cli-base helix-p4d-base helix-git-fusion-base
            ```

         1.  **For CentOS/RHEL:**

            ```bash
            sudo yum remove helix-cli-base helix-p4d-base helix-git-fusion-base
            ```

1.  Optional: **Remove the $GitSwarm$ directory:**

    After removing all $GitSwarm$ data, and the $GitSwarm$ packages and
    dependencies, the directory `/opt/gitswarm` may continue to exist. If
    so and you wish to remove this directory, run:

    ```bash
    sudo rm -rf /opt/gitswarm
    ```
