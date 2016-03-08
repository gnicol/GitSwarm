# Helix Git Fusion permissions

It is possible to enforce the permissions of Helix Git Fusion users within
GitSwarm EE. This feature is available for Helix Git Fusion 2015.4, or
newer.

> **Warning: This capability is not enabled by default, nor do we recommend
  that you enable it.**

## Requirements

- Helix Git Fusions 2015.4, or newer

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
    the user's email address, which could be different between GitSwarm EE
    and Git Fusion), the `ignore-author-permissions` field must be set to
    `yes` in the `p4gf_config` file (the global file, or the per-repo
    file):

    ```
    [git-to-perforce]
    ignore-author-permissions = yes
    ```

    > Note: Ensure that the `unknown_git` user exists in the Helix
    Versioning Engine.

1.  If you want to allow GitSwarm EE users to pushg changes that are
    mirrored into the Helix Versioning Engine (p4d), and those users do not
    exist in p4d, the `unknown_git` user must be added to the
    `git-fusion-push` group. Execute this command:

    ```bash
    p4 group git-fusion-push
    ```

    and add `unknown_git` to the `Users:` section.

1.  Permission enforcement in GitSwarm EE can be global or
    project-specific. To enforce permissions globally, edit
    `/etc/gitswarm/gitswarm.rb` and set:
    
    ```ruby
    gitswarm['git-fusion']['global']['enforce_permissions'] = true
    ```

    To enforce permissions for a specific project, edit
    `/etc/gitswarm/gitswarm.rb` and set:
    
    ```ruby
    gitswarm['git-fusion']['my_identifier']['enforce_permissions'] = true
    ```

    Replace `my_identifier` with the common identifier used by your project
    and Git Fusion.

1.  If you need to enforce read permissions on GitSwarm EE projects, as
    defined in the Helix Versioning Engine's `protect` rules, make sure
    that the GitSwarm EE project's visibility is set to `private`.
