# Uninstall GitSwarm

To uninstall GitSwarm, follow these steps:

1.  **Stop GitSwarm and its supervisory processes.**

    ```
sudo gitswarm-ctl uninstall
    ```

2.  **Remove the GitSwarm package.**

    1.  **For Ubuntu:**

        ```
sudo dpkg --purge perforce-gitswarm
        ```

    2.  **For CentOS/RHEL:**

        ```
sudo rpm -e perforce-gitswarm
        ```

## Optional alternative uninstallation steps

If you prefer to remove all GitSwarm data, use:

```
sudo gitswarm-ctl cleanse
```

To remove all users and groups created by GitSwarm, prior to removing
the GitSwarm package, run:

```
sudo gitswarm-ctl remove_users.
```

Note: All GitSwarm processes need to be stopped before running the
`remove_users` command.
