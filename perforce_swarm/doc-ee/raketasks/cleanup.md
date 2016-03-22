# Cleanup

## Remove garbage from filesystem. Important! Data loss!

Remove namespaces (dirs) from `/var/opt/gitswarm/repositories` if they
don't exist in the GitSwarm EE database.

```bash
sudo gitswarm-rake gitswarm:cleanup:dirs
```

Rename repositories from `/var/opt/gitswarm/repositories` if they don't
exist in GitSwarm EE database. The repositories get a `+orphaned+TIMESTAMP`
suffix so that they cannot block new repositories from being created.

```bash
sudo gitswarm-rake gitswarm:cleanup:repos
```
