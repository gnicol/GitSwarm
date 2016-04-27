# Enable HTTPS

> **Warning:** The NGINX config tells browsers and clients to only
> communicate with your GitSwarm EE instance over a secure connection for
> the next 24 months. By enabling HTTPS you'll need to provide a secure
> connection to your instance for at least the next 24 months.

By default, GitSwarm EE does not use HTTPS. If you want to enable HTTPS
for `gitswarm.example.com`, add the following statement to
`/etc/gitswarm/gitswarm.rb`:

```ruby
# note the 'https' below
external_url "https://gitswarm.example.com"
```

Because the hostname in our example is 'gitswarm.example.com', GitSwarm EE
looks for the key and certificate files called
`/etc/gitswarm/ssl/gitswarm.example.com.key` and
`/etc/gitswarm/ssl/gitswarm.example.com.crt`, respectively. Create the
`/etc/gitswarm/ssl` directory and copy your key and certificate there.

```bash
sudo mkdir -p /etc/gitswarm/ssl
sudo chmod 700 /etc/gitswarm/ssl
sudo cp gitswarm.example.com.key gitswarm.example.com.crt /etc/gitswarm/ssl/
```

Now run `sudo gitswarm-ctl reconfigure`. When the reconfigure finishes, your
GitSwarm EE instance should be reachable at `https://gitswarm.example.com`.

If you are using a firewall you may have to open port 443 to allow inbound
HTTPS traffic.

```bash
# UFW example (Debian, Ubuntu)
sudo ufw allow https

# lokkit example (RedHat, CentOS 6)
sudo lokkit -s https

# firewall-cmd (RedHat, Centos 7)
sudo firewall-cmd --permanent --add-service=https
sudo systemctl reload firewalld
```

## Redirect `HTTP` requests to `HTTPS`

By default, when you specify an `external_url` starting with `https`, NGINX
no longer listens for unencrypted HTTP traffic on port 80. If you want to
redirect all HTTP traffic to HTTPS you can use the `redirect_http_to_https`
setting.

```ruby
external_url "https://gitswarm.example.com"
nginx['redirect_http_to_https'] = true
```

## Change the default port and the SSL certificate locations

If you need to use an HTTPS port other than the default (443), just specify
it as part of the `external_url`.

```ruby
external_url "https://gitswarm.example.com:2443"
```

To set the location of SSL certificates create `/etc/gitswarm/ssl`
directory, place the `.crt` and `.key` files in the directory and specify
the following configuration in `/etc/gitswarm/gitswarm.rb`:

```ruby
# For GitSwarm EE
nginx['ssl_certificate'] = "/etc/gitswarm/ssl/gitswarm.example.crt"
nginx['ssl_certificate_key'] = "/etc/gitswarm/ssl/gitswarm.example.com.key"
```

Run `sudo gitswarm-ctl reconfigure` for the change to take effect.

## Change the default proxy headers

By default, when you specify `external_url` GitSwarm EE sets a few
NGINX proxy headers that are assumed to be sane in most environments.

For example, GitSwarm EE sets:

```
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl" => "on"
```

if you have specified `https` schema in the `external_url`.

However, if you have a situation where your GitSwarm EE is in a more
complex setup like behind a reverse proxy, you need to tweak the proxy
headers in order to avoid errors like `The change you wanted was rejected`
or `Can't verify CSRF token authenticity Completed 422 Unprocessable`.

This can be achieved by overriding the default headers, eg. specify
in `/etc/gitswarm/gitswarm.rb`:

```ruby
nginx['proxy_set_headers'] = {
 "X-Forwarded-Proto" => "http",
 "CUSTOM_HEADER" => "VALUE"
}
```

Save the file and run `sudo gitswarm-ctl reconfigure` for the changes to
take effect.

This way you can specify any header supported by NGINX you require.

## Configuring HTTP2 protocol

By default, when you specify that your GitSwarm EE instance should be
reachable through HTTPS by specifying `external_url
"https://gitswarm.example.com"`, [http2 protocol] is also enabled.

GitSwarm EE sets the required `ssl_ciphers` that are compatible with the
http2 protocol.

If you are specifying custom `ssl_ciphers` in your configuration and a
cipher is in [http2 cipher blacklist], once you try to reach your GitSwarm
EE instance you should be presented with `INADEQUATE_SECURITY` error in
your browser.

Consider removing the offending ciphers from the cipher list. Changing
ciphers is only necessary if you have a very specific custom setup.

For more info on why you would want to have http2 protocol enabled, check
out the [http2 whitepaper].

If changing the ciphers is not an option you can disable http2 support by
specifying in `/etc/gitswarm/gitswarm.rb`:

```ruby
nginx['http2_enabled'] = false
```

Save the file and run `sudo gitswarm-ctl reconfigure` for the changes to
take effect.

## Using a non-bundled web-server

By default, GitSwarm EE bundles NGINX. GitSwarm EE allows webserver access
through user `gitlab-www` which resides in the group with the same name. To
allow an external webserver access to GitSwarmEE , the external webserver
user needs to be added `gitlab-www` group.

To use another web server like Apache or an existing NGINX installation you
have to perform the following steps:

1. **Disable bundled NGINX**

    In `/etc/gitswarm/gitswarm.rb` set:

    ```ruby
    nginx['enable'] = false
    ```

1. **Set the username of the non-bundled web-server user**

    By default, GitSwarm EE has no default setting for the external
    webserver user, you have to specify it in the configuration. For
    Debian/Ubuntu the default user is `www-data` for both Apache/NGINX
    whereas for RHEL/CentOS the NGINX user is `nginx`.

    > **Note:** Make sure you have first installed Apache/NGINX so the
    > webserver user is created, otherwise GitSwarm EE's reconfigure fails.

    Let's say for example that the webserver user is `www-data`.
    In `/etc/gitswarm/gitswarm.rb` set:

    ```ruby
    web_server['external_users'] = ['www-data']
    ```

    > **Note:** This setting is an array so you can specify more than one
    > user to be added to `gitlab-www` group.

    Run `sudo gitswarm-ctl reconfigure` for the change to take effect.

    > **Note:** if you are using SELinux and your web server runs under a
    > restricted SELinux profile you may have to [loosen the restrictions
    > on your web server][selinuxmod].

    > **Note:** make sure that the webserver user has the correct
    > permissions on all directories used by external web-server, otherwise
    > you receive `failed (XX: Permission denied) while reading upstream`
    > errors.

1. **(Optional) Set the right gitlab-workhorse settings if using Apache**

    > **Note:** The values below were added in GitSwarm EE 2015.4, make
    > sure you have the latest version installed.

    Apache cannot connect to a UNIX socket but instead needs to connect to
    a TCP Port. To allow gitlab-workhorse to listen on TCP (by default port
    8181) edit `/etc/gitswarm/gitswarm.rb`:

    ```
    gitlab_workhorse['listen_network'] = "tcp"
    gitlab_workhorse['listen_addr'] = "127.0.0.1:8181"
    ```

    Run `sudo gitswarm-ctl reconfigure` for the change to take effect.

1. **Download the right web server configs**

    Go to the [GitLab recipes repository][recipes-web] and look for the
    webserver configs in the webserver directory of your choice. Make sure
    you pick the right configuration file depending whether you choose to
    serve GitSwarm EE with SSL or not. The only thing you need to change is
    `YOUR_SERVER_FQDN` with your own FQDN and if you use SSL, the location
    where your SSL keys currently reside. You also might need to change the
    location of your log files.

## Setting the NGINX listen address or addresses

By default, NGINX accepts incoming connections on all local IPv4 addresses.
You can change the list of addresses in `/etc/gitswarm/gitswarm.rb`.

```ruby
# listen on all IPv4 and IPv6 addresses
nginx['listen_addresses'] = ["0.0.0.0", "[::]"]
```

## Setting the NGINX listen port

By default, NGINX listens on the port specified in `external_url` or
implicitly use the right port (80 for HTTP, 443 for HTTPS). If you are
running GitSwarm EE behind a reverse proxy, you may want to override the
listen port to something else. For example, to use port 8080:

```ruby
nginx['listen_port'] = 8080
```

## Supporting proxied SSL

By default, NGINX auto-detects whether to use SSL if `external_url`
contains `https://`. If you are running GitSwarm EE behind a reverse proxy,
you may wish to terminate SSL at another proxy server or load balancer. To
do this, be sure the `external_url` contains `https://` and apply the
following configuration to `/etc/gitswarm/gitswarm.rb`:

```ruby
nginx['listen_port'] = 80
nginx['listen_https'] = false
nginx['proxy_set_headers'] = {
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl" => "on"
}
```

Note that you may need to configure your reverse proxy or load balancer to
forward certain headers (e.g. `Host`, `X-Forwarded-Ssl`, `X-Forwarded-For`,
`X-Forwarded-Port`) to GitSwarm EE. You may see improper redirections or
errors (e.g. "422 Unprocessable Entity", "Can't verify CSRF token
authenticity") if you forget this step. For more information, see:

* http://stackoverflow.com/questions/16042647/whats-the-de-facto-standard-for-a-reverse-proxy-to-tell-the-backend-ssl-is-used
* https://wiki.apache.org/couchdb/Nginx_As_a_Reverse_Proxy

## Using custom SSL ciphers

By default GitSwarm EE uses best practices SSL ciphers. However, you can
change the ssl ciphers by adding to `/etc/gitswarm/gitswarm.rb`:

```ruby
nginx['ssl_ciphers'] = "CIPHER:CIPHER1"
```

and running reconfigure.

You can also enable `ssl_dhparam` directive.

First, generate `dhparams.pem` with:

```bash
openssl dhparam -out /etc/gitswarm/ssl/dhparams.pem 2048
```

Then, in `/etc/gitswarm/gitswarm.rb` add a path to the generated file, for
example:

```ruby
nginx['ssl_dhparam'] = "/etc/gitswarm/ssl/dhparams.pem"
```

After the change run `sudo gitswarm-ctl reconfigure`.

## Inserting custom NGINX settings into the GitSwarm EE server block

If you need to add custom settings into the NGINX `server` block for
GitSwarm EE for some reason you can use the following setting.

```ruby
# Example: block raw file downloads from a specific repository
nginx['custom_gitlab_server_config'] = "location ^~ /foo-namespace/bar-project/raw/ {\n deny all;\n}\n"
```

Run `sudo gitswarm-ctl reconfigure` to rewrite the NGINX configuration and
restart NGINX.

## Inserting custom settings into the NGINX config

If you need to add custom settings into the NGINX config, for example to
include existing server blocks, you can use the following setting.

```ruby
# Example: include a directory to scan for additional config files
nginx['custom_nginx_config'] = "include /etc/nginx/conf.d/*.conf;"
```

Run `sudo gitswarm-ctl reconfigure` to rewrite the NGINX configuration and
restart NGINX.

## Using an existing Passenger/Nginx installation

In some cases you may want to host GitSwarm EE using an existing
Passenger/NGINX installation but still have the convenience of updating and
installing using the GitSwarm EE packages.

### Configuration

First, you'll need to setup your `/etc/gitswarm/gitswarm.rb` to disable the
built-in NGINX and Unicorn:

```ruby
# Disable the built-in NGINX
nginx['enable'] = false

# Disable the built-in Unicorn
unicorn['enable'] = false

# Set the internal API URL
gitlab_rails['internal_api_url'] = 'http://gitswarm.yourdomain.com'
```

Make sure you run `sudo gitswarm-ctl reconfigure` for the changes to take
effect.

### Vhost (server block)

Then, in your custom Passenger/NGINX installation, create the following
site configuration file:

```
upstream gitlab-workhorse {
  server unix://var/opt/gitswarm/gitlab-workhorse/socket fail_timeout=0;
}

server {
  listen *:80;
  server_name git.example.com;
  server_tokens off;
  root /opt/gitswarm/embedded/service/gitlab-rails/public;

  client_max_body_size 250m;

  access_log  /var/log/gitswarm/nginx/gitlab_access.log;
  error_log   /var/log/gitswarm/nginx/gitlab_error.log;

  # Ensure Passenger uses the bundled Ruby version
  passenger_ruby /opt/gitswarm/embedded/bin/ruby;

  # Correct the $PATH variable to included packaged executables
  passenger_env_var PATH "/opt/gitswarm/bin:/opt/gitswarm/embedded/bin:/usr/local/bin:/usr/bin:/bin";

  # Make sure Passenger runs as the correct user and group to
  # prevent permission issues
  passenger_user git;
  passenger_group git;

  # Enable Passenger & keep at least one instance running at all times
  passenger_enabled on;
  passenger_min_instances 1;

  location ~ ^/[\w\.-]+/[\w\.-]+/(info/refs|git-upload-pack|git-receive-pack)$ {
    # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
    error_page 418 = @gitlab-workhorse;
    return 418;
  }

  location ~ ^/[\w\.-]+/[\w\.-]+/repository/archive {
    # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
    error_page 418 = @gitlab-workhorse;
    return 418;
  }

  location ~ ^/api/v3/projects/.*/repository/archive {
    # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
    error_page 418 = @gitlab-workhorse;
    return 418;
  }

  # Build artifacts should be submitted to this location
  location ~ ^/[\w\.-]+/[\w\.-]+/builds/download {
      client_max_body_size 0;
      # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
      error_page 418 = @gitlab-workhorse;
      return 418;
  }

  # Build artifacts should be submitted to this location
  location ~ /ci/api/v1/builds/[0-9]+/artifacts {
      client_max_body_size 0;
      # 'Error' 418 is a hack to re-use the @gitlab-workhorse block
      error_page 418 = @gitlab-workhorse;
      return 418;
  }

  location @gitlab-workhorse {

    ## https://github.com/gitlabhq/gitlabhq/issues/694
    ## Some requests take more than 30 seconds.
    proxy_read_timeout      300;
    proxy_connect_timeout   300;
    proxy_redirect          off;

    # Do not buffer Git HTTP responses
    proxy_buffering off;

    proxy_set_header    Host                $http_host;
    proxy_set_header    X-Real-IP           $remote_addr;
    proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
    proxy_set_header    X-Forwarded-Proto   $scheme;

    proxy_pass http://gitlab-workhorse;

    ## The following settings only work with NGINX 1.7.11 or newer
    #
    ## Pass chunked request bodies to gitlab-workhorse as-is
    # proxy_request_buffering off;
    # proxy_http_version 1.1;
  }

  ## Enable gzip compression as per rails guide:
  ## http://guides.rubyonrails.org/asset_pipeline.html#gzip-compression
  ## WARNING: If you are using relative urls remove the block below
  ## See config/application.rb under "Relative url support" for the list of
  ## other files that need to be changed for relative url support
  location ~ ^/(assets)/ {
    root /opt/gitswarm/embedded/service/gitlab-rails/public;
    gzip_static on; # to serve pre-gzipped version
    expires max;
    add_header Cache-Control public;
  }

  error_page 502 /502.html;
}
```

#### Warning

To ensure that user uploads are accessible your NGINX user (usually
`www-data`) should be added to the `gitlab-www` group. This can be done
using the following command:

```bash
sudo usermod -aG gitlab-www www-data
```

#### Templates

Other than the Passenger configuration in place of Unicorn and the lack of
HTTPS (although this could be enabled) these files are mostly identical to
the bundled GitSwarm EE NGINX configuration (in
`/opt/gitswarm/embedded/cookbooks/gitlab/templates/default/nginx-gitlab-http.conf.erb`).

Don't forget to restart NGINX to load the new configuration (on
Debian-based systems `sudo service nginx restart`).

[recipes-web]: https://gitlab.com/gitlab-org/gitlab-recipes/tree/master/web-server
[selinuxmod]: https://gitlab.com/gitlab-org/gitlab-recipes/tree/master/web-server/apache#selinux-modifications
[http2 protocol]: https://tools.ietf.org/html/rfc7540
[http2 whitepaper]: https://assets.wp.nginx.com/wp-content/uploads/2015/09/NGINX_HTTP2_White_Paper_v4.pdf?_ga=1.127086286.212780517.1454411744
[http2 cipher blacklist]: https://tools.ietf.org/html/rfc7540#appendix-A
