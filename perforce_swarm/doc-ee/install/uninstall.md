# Uninstall GitSwarm EE

To uninstall GitSwarm EE, follow these steps:

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

1.  **Stop GitSwarm EE /Remove Data**

    If you are intending to reinstall GitSwarm EE on the machine and keep your existing data:
    ```
sudo gitswarm-ctl stop
    ```

    If you instead want to completely remove all the GitSwarm EE data, run
    ```
sudo gitsawrm-ctl cleanse
    ```

1.  **Uninstall GitSwarm EE's supervisory processes.**

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

1.  **Optional:**, Remove dependencies

    1.  **For Ubuntu:**

        ```
sudo dpkg --remove perforce-cli-base perforce-server-base helix-git-fusion-base
        ```

    1.  **For CentOS/RHEL:**

        ```
sudo rpm -e perforce-cli-base perforce-server-base helix-git-fusion-base
        ```

## Notes on Reinstalling

If you are planning to reinstall GitSwarm EE on the same machine, using the same data, as long as you did not `cleanse`
the data, you can restore the default Helix server by running the following steps:

```
sudo mv ~/gitswarm.conf.backup /etc/perforce/p4dctl.conf.d/gitswarm.conf
sudo p4dctl start gitswarm
```

And then following the normal [installation steps](README.md) for your OS distribution.

**Note:** Otherwise, if you need to restore you data on a fresh install of GitSwarm EE, you will need to
[restore from a backup](../raketasks/backup_restore.md).