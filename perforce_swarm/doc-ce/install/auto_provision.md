# Auto provision

By default GitSwarm will automatically provision a Helix Server and connected Helix Git Fusion for you.

If you wish to use an existing Helix Git Fusion instance you can change the 'url' from:

- gitswarm['git-fusion']['default']['url']               = :auto-provision

to:

- gitswarm['git-fusion']['default']['url']               = 'https://gitswarm@git-fusion.host'   # For HTTP(S)
- gitswarm['git-fusion']['default']['password']          = '<PASSWORD>'                         # For HTTP(S)
- gitswarm['git-fusion']['default']['git_config_params'] = 'http.maxRequests=5'                 # For HTTP(S)

or:

- gitswarm['git-fusion']['default']['url']               = 'git@git-fusion.host'                # For SSH

If specified the default Helix server will have the following configuration (the configure-perforce-server.sh script 
provided by the Helix server package is executed):

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
