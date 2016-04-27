# Supporting Large Pushes

If you are planning to push large mirrored projects to $GitSwarm$, we recommend
that you use SSH. If you encounter failures due to large pushes, or are only
able to use HTTP/S, the following changes made to `/etc/gitswarm/gitswarm.rb`
may be of help:

    nginx['client_max_body_size']  = '0m'
    nginx['proxy_read_timeout']    = 1000
    nginx['proxy_connect_timeout'] = 1000
