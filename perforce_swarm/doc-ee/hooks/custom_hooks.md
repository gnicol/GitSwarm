# Custom Git Hooks

**Note: Custom git hooks must be configured on the filesystem of the
GitSwarm EE server. Only GitSwarm EE server administrators will be able to
complete these tasks. Please explore [webhooks](../web_hooks/web_hooks.md)
as an option if you do not have filesystem access.**

Git natively supports hooks that are executed on different actions.
Examples of server-side git hooks include pre-receive, post-receive, and
update. See [Git SCM Server-Side
Hooks](http://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#Server-Side-Hooks)
for more information about each hook type.

GitSwarm EE administrators can add custom git hooks to any GitSwarm EE
project.

## Setup

Normally, git hooks are placed in the repository or project's `hooks`
directory. GitSwarm EE creates a symlink from each project's `hooks`
directory to the gitswarm-shell `hooks` directory for ease of maintenance
between gitswarm-shell upgrades. As such, custom hooks are implemented a
little differently. Behavior is exactly the same once the hook is created,
though.  Follow these steps to set up a custom hook.

1. Pick a project that needs a custom git hook.
1. On the GitSwarm EE server, navigate to the project's repository
   directory. The path is usually
   `/var/opt/gitswarm/git-data/repositories/<group>/<project>.git`.
1. Create a new directory in this location called `custom_hooks`.
1. Inside the new `custom_hooks` directory, create a file with a name
   matching the hook type. For a pre-receive hook the file name should be
   `pre-receive` with no extension.
1. Make the hook file executable and make sure it's owned by `git`.
1. Write the code to make the git hook function as expected. Hooks can be
   in any language. Ensure the 'shebang' at the top properly reflects the
   language type. For example, if the script is in Ruby the shebang will
   probably be `#!/usr/bin/env ruby`.

That's it! Assuming the hook code is properly implemented, the hook will
fire as appropriate.
