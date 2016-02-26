# GitSwarm EE Git LFS Administration

Documentation on how to use Git LFS are under [Managing large binary files
with Git LFS doc](manage_large_binaries_with_git_lfs.md).

## Requirements

*   Git LFS is supported in GitSwarm EE starting with version 2016.1.
*   Users need to install [Git LFS client](https://git-lfs.github.com)
*   version 1.0.1 and up.

## Configuration

Git LFS objects can be large in size. By default, they are stored on the
server GitSwarm EE is installed on.

There are two configuration options to help GitSwarm EE server
administrators:

*   Enabling/disabling Git LFS support
 
*   Changing the location of LFS object storage

In `/etc/gitswarm/gitswarm.rb`:

```ruby
gitlab_rails['lfs_enabled'] = false
gitlab_rails['lfs_storage_path'] = "/mnt/storage/lfs-objects"
```

## Known limitations

*   Currently, storing GitSwarm EE Git LFS objects on a non-local storage
    (like S3 buckets) is not supported

*   Currently, removing LFS objects from GitSwarm EE Git LFS storage is not
    supported
