# User management

## Add user as a developer to all projects

```bash
sudo gitswarm-rake gitswarm:import:user_to_projects[username@domain.tld]
```

## Add all users to all projects

```bash
sudo gitswarm-rake gitswarm:import:all_users_to_all_projects
```

> Note: admin users are added as masters

## Add user as a developer to all groups

```bash
sudo gitswarm-rake gitswarm:import:user_to_groups[username@domain.tld]
```

## Add all users to all groups

```bash
sudo gitswarm-rake gitswarm:import:all_users_to_all_groups
```

> Note: admin users are added as owners so they can add additional users to
> the group

## Maintain tight control over the number of active users on your GitSwarm EE installation

Enable this setting to keep new users blocked until they have been cleared
by the admin (default: false).

```
block_auto_created_users: false
```

## Disable Two-factor Authentication (2FA) for all users

This task will disable 2FA for all users that have it enabled. This can be
useful if GitSwarm EE's `.secret` file has been lost and users are unable to
login, for example.

```bash
sudo gitswarm-rake gitswarm:two_factor:disable_for_all_users
```
