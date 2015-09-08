# Auto provision

By default GitSwarm will automatically provision a Helix Server and connected Helix Git Fusion for you.

If you wish to use an existing Helix Git Fusion instance you can change the 'url' from:
```
gitswarm['git-fusion']['default']['url']               = :auto-provision
```

If you are using HTTP(s) to communicate with Helix Git Fusion:

```
gitswarm['git-fusion']['default']['url']               = 'https://gitswarm@git-fusion.host'
gitswarm['git-fusion']['default']['password']          = '<PASSWORD>'
gitswarm['git-fusion']['default']['git_config_params'] = 'http.maxRequests=5'
```

or if you are using SSH to communicate with Helix Git Fusion:

```
gitswarm['git-fusion']['default']['url']               = 'git@git-fusion.host'
```

Note the default configuration includes details on the perforce user and perforce password; these values will likely require adjustment when pointing at an external Helix Git Fusion instance.

When using GitSwarm is left in auto-provision mode, the Helix Server is configured with the following configuration:

- Port 
    - ssl:1666
- Users 
    - gitswarm (password generated and stored in /etc/gitswarm/gitswarm.rb, super user privilege)
    - root (password default '5iveL!fe', super user privilege)
- Root
    - /var/opt/gitswarm/perforce/data
- Unicode enabled
- Case sensitive
- Depot 'gitswarm'
- p4dctl is used to interact with the server and is configured in /etc/perforce/p4dctl.conf.d/gitswarm.conf

When the 'root' user password is updated from the GitSwarm UI the password change will also take effect for the 
'root' Perforce user. 

If :auto_provision is not specified in /etc/gitswarm/gitswarm.rb when 'gitswarm-ctl reconfigure' is executed any 
running auto provisioned instance will be shut down and disabled from automatic start up on boot in the p4dctl 
configuration.

The following steps are taken when a default Helix Git Fusion is configured:

- The configure-git-fusion script provided by the package is executed
- An SSH key is generated for the 'git-fusion' OS user
- A temporary P4 client is used to check this key into Perforce
- A cron task configured in /etc/cron.d/perforce-git-fusion is created to check for new user keys and update
  ~git-fusion/.ssh/authorized_keys

If :auto_provision is not specified in /etc/gitswarm/gitswarm.rb when 'gitswarm-ctl reconfigure'
is executed the cron task will be removed.