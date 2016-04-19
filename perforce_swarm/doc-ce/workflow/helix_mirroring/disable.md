[Help](../../README.md)
/ [Workflow](../README.md)
/ [Helix Mirroring](README.md)
/ Disable

## Disable

Once Helix Mirroring has been [enabled](enable.md), it can be disabled.
When disabled, the Git Fusion [configuration](configuration.md) remains in
the `/etc/gitswarm/gitswarm.rb` file. Projects that have disabled Helix
Mirroring should display 'Not mirrored in Helix'.

> **Note:** Your GitSwarm user account must either be an admin account, or
> you must have at least master-level permissions for the project on which
> you are attempting to disable mirroring.

To disable Helix Mirroring for a project:

1.  **Visit the project's settings page.**

1.  **Click "Helix Mirroring".**

1.  **Click the "Disable Helix Mirroring" button.**

    You are prompted **Are you sure?**.

1.  **Click "Yes".**

    The project is no longer mirrored into Helix.

    > **Note:** At this point, the button switches to read **Re-enable
    > Helix Mirroring**. See the [re-enable documentation](reenable.md) for
    > details about re-enabling Helix Mirroring.
