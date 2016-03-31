[Help](../../README.md)
/ [Workflow](../README.md)
/ [Helix Mirroring](README.md)
/ Requirements

## Requirements

*   Helix Git Fusion 2015.2, or newer.
*   Helix GitSwarm EE 2015.3, or newer.
*   Helix Versioning Engine (P4D) version 2015.1/1171507, or newer.
    *   A user for GitSwarm EE's use in the Helix Versioning Engine with
        the following attributes:
        *   a normal user (not operator or service users)
        *   a member of the `git-fusion-pull` group
        *   must have write access via Helix protections to:
            *   `//.git-fusion/repos/...` (to allow GitSwarm EE to create
                `auto_create` repos)
            *   `//.git-fusion/users/<GitSwarm EE user>/...` (for SSH
                access)
            *   `//<all Git Fusion depot roots accessed by GitSwarm EE>`

## Recommendations

*   Install GitSwarm EE and Git Fusion on separate machines to improve
    performance and scalability. GitSwarm EE 2015.3+ installs with an
    auto-provided Helix Versioning Engine and an auto-providsioned Git
    Fusion server, all pre-configured to allow you to easily try out the
    system. In production, we recommend disabling the auto-provisioned Git
    Fusion, and using an external one. [Check out the docs on the
    auto-provisioned Git Fusion](../../install/auto_provision.md))

*   Use SSH or HTTPS connections to secure the mirroring connections.
    SSH connections are faster and more secure. We recommend against using
    unencrypted HTTP connections or HTTPS with self-signed certificates.
