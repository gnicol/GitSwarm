# Public access

GitSwarm allows you to open selected projects to be accessed **publicly**
or **internally**.

Projects with either of these visibility levels will be listed in the
[public access directory](/public).

Internal projects will only be available to authenticated users.

## Public projects

Public projects can be cloned **without any** authentication.

It will also be listed on the [public access directory](/public).

**Any logged in user** will have [Guest](../permissions/permissions.md)
permissions on the repository.

## Internal projects

Internal projects can be cloned by any logged in user.

It will also be listed on the [public access directory](/public) for logged
in users.

Any logged in user will have [Guest](../permissions/permissions.md)
permissions on the repository.

## How to change project visibility

1. Go to your project dashboard
1. Click on the "Edit" tab
1. Change "Visibility Level"

## Visibility of users

The public page of users, located at `/u/username` is visible if either:

- You are logged in.
- You are logged out, and the target user is authorized to (is Guest,
  Reporter, etc.) at least one public project.

Otherwise, you will be redirected to the sign in page.

When visiting the public page of an user, you will only see listed projects which you can view yourself.

## Restricting the use of public or internal projects

You can disable public projects, or public and internal projects, for the
entire GitSwarm installation to prevent people from making code public by
accident.

To do so, add (or modify) the following lines in the configuration file
`/etc/gitswarm/gitlab.rb`:

```
# Control visibility of projects; default value is nil
# nil = public and internal projects are visible
# ['public', 'internal'] = make public and internal project invisible
gitlab_rails['gitlab_restricted_visibility_levels'] = nil
```
