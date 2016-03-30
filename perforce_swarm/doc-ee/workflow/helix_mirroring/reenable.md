[Help](../../README.md)
/ [Workflow](../README.md)
/ [Helix Mirroring](README.md)
/ Re-enable

## Re-enable

Often, when Helix Mirroring has been enabled for a project, and
subsequently disabled, it can later be re-enabled. In certain situations,
it just works. In others, additional work needs to be done first.

-   Generally, if Helix Mirroring has been disabled, you can re-enable
    mirroring there are no changes within GitSwarm EE and the Helix
    Versioning Engine (p4d), or when any changes are strictly within
    GitSwarm EE or p4d, but not both.

-   When work has progressed both in GitSwarm EE and p4d after Helix
    Mirroring was disabled, you need to manually perform a merge via the
    command line using the following steps:
    1.  Clone from the Git Fusion repo associated with the GitSwarm EE
        project.
    1.  Add GitSwarm EE's project repo as another remote.
    1.  Pull changes from the GitSwarm EE remote and, where necessary,
        manually merge in the changes.
    1.  Push the updated repo to Git Fusion.
    1.  Try to re-enable Helix Mirroring.

-   Helix Mirroring does not support force pushes. If you cannot adjust
    your workflow to avoid force pushes, you can try force pushing to a
    task branch that is not mirrored, and then merging changes into a
    mirrored branch.

> **Note:** Your GitSwarm EE user account must either be an admin account,
> or you must have at least master-level permissions for the project on
> which you are attempting to re-enable mirroring.

### How to re-enable Helix Mirroring:

1.  **Visit the project's settings page.**

1.  **Click "Helix Mirroring".**

1.  **Click "Re-enable Helix Mirroring".**

    You are prompted **Are you sure?**.

1.  **Click "Yes".**

    If possible, mirroring is re-enabled for the project.
