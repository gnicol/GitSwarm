# Helix Git Fusion permissions

It is possible to enforce the permissions of Helix Git Fusion users within
GitSwarm. This feature is available for Helix Git Fusion 2015.4, or
newer.

> Note: This capability is not enabled by default, nor do we recommend that
        you enable it.

## Enable permission enforcement

To enable permission enforcement via Git Fusion, you need to:

1.  Edit the `p4gf_config` file (the global file, or the per-repo file), and
    set the `read-permission-check` field to `user`:

    ```
[git-to-perforce]
read-permission-check = user
    ```

1.  Set the Helix Versioning Engine key
    `git-fusion-permission-group-default` to `push`:

    ```bash
p4 key git-fusion-permission-group-default push
    ```

1.  To ensure that authentication is based solely on userid (ignoring
    the user's email address, which could be different between GitSwarm and
    Git Fusion), the `ignore-author-permissions` field must be set to `yes`
    in the `p4gf_config` file (the global file, or the per-repo
    file):

    ```
[git-to-perforce]
ignore-author-permissions = yes
    ```

> NOTE: Ensure that the `unknown_git` user exists in the Helix Versioning
        Engine.
