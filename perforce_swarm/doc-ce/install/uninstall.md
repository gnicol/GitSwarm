# Uninstall GitSwarm

To uninstall GitSwarm, follow these steps:

1.  **If you are using the auto-provisioned Helix Git Fusion service, stop
    the Helix Server (if it is running).**

    Check the status:

    ```
sudo p4dctl status gitswarm
    ```

    If running, shut it down and backup the config:
    ```
sudo p4dctl stop gitswarm
sudo mv /etc/perforce/p4dctl.conf.d/gitswarm.conf ~/gitswarm.conf.backup
sudo cp -a /etc/gitswarm ~/etc.gitswarm.backup
    ```

1.  **Stop GitSwarm.**

    ```
sudo gitswarm-ctl stop
    ```

1.  Optional: **Remove GitSwarm data.**

    If you instead want to **completely remove** all GitSwarm data, run:

    ```
sudo gitswarm-ctl cleanse
    ```

    `Warning: this permanently removes all GitSwarm-related data.`

1.  **Uninstall GitSwarm's supervisory processes.**

    ```
sudo gitswarm-ctl uninstall
    ```

1.  **Uninstall the GitSwarm package.**

    1.  **For Ubuntu:**

        ```
sudo apt-get purge helix-gitswarm
        ```

    1.  **For CentOS:**

        ```
sudo yum remove helix-gitswarm
        ```

1.  **Optional:**, Remove dependencies

    1.  **For Ubuntu:**

        ```
sudo apt-get autoremove
        ```

    1.  **For CentOS:**

        ```
sudo yum remove perforce-cli-base perforce-server-base helix-git-fusion-base
        ```

## Notes on Reinstalling

If you are planning to reinstall GitSwarm on the same machine, using the
same data, as long as you did not `cleanse` the data, you can restore the
default Helix server by running the following steps:

```
sudo cp -a ~/etc.gitswarm.backup /etc/gitswarm
sudo mv ~/gitswarm.conf.backup /etc/perforce/p4dctl.conf.d/gitswarm.conf
sudo p4dctl start gitswarm
```

And then following the normal [installation steps](README.md) for your OS
distribution.

**Note:** Otherwise, if you need to restore your data on a fresh install of
GitSwarm, you will need to [restore from a
backup](../raketasks/backup_restore.md).
