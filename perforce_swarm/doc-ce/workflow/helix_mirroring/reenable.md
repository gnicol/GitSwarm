## Re-enable Helix Mirroring

Often, when Helix mirroring has been enabled for a project, and
subsequently disabled, it can later be re-enabled. In certain situations,
it just works. In others, additional work needs to be done first.

-   Generally, if Helix Mirroring has been disabled, you can re-enable when
    no changes have been provided within the GitSwarm repo, the
    corresponding depot paths in the Helix Versioning Engine (P4D), or
    both.

-   When work has progressed in GitSwarm and P4D, you need to manually
    perform a merge using the following steps:

    1.  Clone from the Git Fusion repo associated with the project.
    1.  Add GitSwarm's project repo as another remote.
    1.  Pull changes from Git Fusion and, where necessary, manually merge
        in the changes.
    1.  Push the updated repo to Git Fusion.
    1.  Try to re-enable Helix Mirroring.

-   Helix Mirroring does not support force pushes. If you cannot adjust
    your workflow to avoid force pushes, you can try force pushing to a
    task branch that is not mirrored, and then merging changes into a
    mirrored branch.

### How to re-enable Helix Mirroring:

1.  Visit the project's settings page.

1.  Click **Re-enable Helix Mirroring**. You are prompted **Are you
    sure?**.

1.  Click **Yes**. If possible, mirroring is re-enabled for the project.
