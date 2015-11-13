# Supporting Large Pushes

Pushing large mirrored projects to GitSwarm over HTTP/S or SSH can hit size and
timeout limits. Large pushes can more easily be supported with the following
changes made to `/etc/gitswarm/gitswarm.rb`:

    nginx['client_max_body_size']  = '0m'
    nginx['proxy_read_timeout']    = 1000
    nginx['proxy_connect_timeout'] = 1000
