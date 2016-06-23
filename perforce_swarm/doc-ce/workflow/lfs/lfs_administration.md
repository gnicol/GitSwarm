# $GitSwarm$ Git LFS Administration

Documentation on how to use Git LFS are under [Managing large binary files
with Git LFS doc](manage_large_binaries_with_git_lfs.md).

## Requirements

*   Git LFS is supported in $GitSwarm$ starting with version 2016.1.
*   Users need to install [Git LFS client](https://git-lfs.github.com)
    version 1.0.1 and up.

## Configuration

Git LFS objects can be large in size. By default, they are stored on the
server $GitSwarm$ is installed on.

There are two configuration options to help $GitSwarm$ server administrators:

*   Enabling/disabling Git LFS support
 
*   Changing the location of LFS object storage

### Package installations

In `/etc/gitswarm/gitswarm.rb`:

```ruby
gitlab_rails['lfs_enabled'] = false

# Optionally, change the storage path location. Defaults to
# `#{gitlab_rails['shared_path']}/lfs-objects`. Which evaluates to
# `/var/opt/gitswarm/gitlab-rails/shared/lfs-objects` by default.
gitlab_rails['lfs_storage_path'] = "/mnt/storage/lfs-objects"
```

### Installations from source

In `config/gitlab.yml`:

```yaml
  lfs:
    enabled: false
    storage_path: /mnt/storage/lfs-objects
```

## Known limitations

* Currently, storing $GitSwarm$ Git LFS objects on a non-local storage
  (like S3 buckets) is not supported
* Currently, removing LFS objects from $GitSwarm$ Git LFS storage is not
  supported
* LFS authentications via SSH is not supported for the time being
* Only compatible with the Git LFS client versions 1.1.0 or 1.0.2.
