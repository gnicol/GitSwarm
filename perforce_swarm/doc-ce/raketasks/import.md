# Import bare repositories into your GitSwarm instance

## Notes

- The owner of the project will be the first admin
- The groups will be created as needed
- The owner of the group will be the first admin
- Existing projects will be skipped

## How to use

### Create a new folder inside the git repositories path.

The repositories path is `/var/opt/gitlab/git-data/repositories` by
default, unless you changed it in the `/etc/gitswarm/gitswarm.rb` file.

The folder name becomes the name of the new group.

The new folder needs to have git user ownership and read/write/execute
access for git user and its group:

```bash
sudo -u git mkdir /var/opt/gitswarm/git-data/repositories/new_group
```

### Copy your bare repositories inside this newly created folder:

```bash
sudo cp -r /old/git/foo.git /var/opt/gitswarm/git-data/repositories/new_group/

# Do this once when you are done copying git repositories
sudo chown -R git:git /var/opt/gitswarm/git-data/repositories/new_group/
```

`foo.git` needs to be owned by the git user and git users group.

### Import the repositories

```bash
sudo gitswarm-rake gitswarm:import:repos
```

#### Example output

```
Processing abcd.git
 * Created abcd (abcd.git)
Processing group/xyz.git
 * Created Group group (2)
 * Created xyz (group/xyz.git)
[...]
```
