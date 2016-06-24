# $GitSwarm$ Container Registry Administration

> **Note:** This feature was introduced in GitSwarm 2016.2.

With the Docker Container Registry integrated into $GitSwarm$, every
project can have its own space to store its Docker images.

You can read more about Docker Registry at
https://docs.docker.com/registry/introduction/.

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Enable the Container Registry](#enable-the-container-registry)
- [Container Registry domain configuration](#container-registry-domain-configuration)
    - [Configure Container Registry under an existing $GitSwarm$ domain](#configure-container-registry-under-an-existing-$GitSwarmPackage$-domain)
    - [Configure Container Registry under its own domain](#configure-container-registry-under-its-own-domain)
- [Disable Container Registry site-wide](#disable-container-registry-site-wide)
- [Disable Container Registry per project](#disable-container-registry-per-project)
- [Disable Container Registry for new projects site-wide](#disable-container-registry-for-new-projects-site-wide)
- [Container Registry storage path](#container-registry-storage-path)
- [Storage limitations](#storage-limitations)
- [Changelog](#changelog)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Enable the Container Registry

**Package installations**

All you have to do is configure the domain name under which the Container
Registry will listen to. Read [#container-registry-domain-configuration](#container-registry-domain-configuration)
and pick one of the two options that fits your case.

> **Note:** The container Registry works under HTTPS by default. Using HTTP
> is possible but not recommended and out of the scope of this document.
> Read the [insecure Registry documentation][docker-insecure] if you want
> to implement this.

---

**Source installations**

If you have installed $GitSwarm$ from source:

1.  You have to [install Docker Registry][registry-deploy] by yourself.
1.  After the installation is complete, you will have to configure the
    Registry's settings in `gitlab.yml` in order to enable it.
1.  Use the sample Nginx configuration file that is found under
    [`lib/support/nginx/registry-ssl`][registry-ssl] and edit it to match
    the `host`, `port` and TLS certs paths.

The contents of `gitlab.yml` are:

```
registry:
  enabled: true
  host: registry.gitswarm.example.com
  port: 5005
  api_url: http://localhost:5000/
  key_path: config/registry.key
  path: shared/registry
  issuer: gitlab-issuer
```

where:

| Parameter | Description |
| --------- | ----------- |
| `enabled` | `true` or `false`. Enables the Registry in $GitSwarm$. By default this is `false`. |
| `host`    | The host URL under which the Registry will run and the users will be able to use. |
| `port`    | The port under which the external Registry domain will listen on. |
| `api_url` | The internal API URL under which the Registry is exposed to. It defaults to `http://localhost:5000`. |
| `key_path`| The private key location that is a pair of Registry's `rootcertbundle`. Read the [token auth configuration documentation][token-config]. |
| `path`    | This should be the same directory like specified in Registry's `rootdirectory`. Read the [storage configuration documentation][storage-config]. This path needs to be readable by the $GitSwarm$ user, the web-server user and the Registry user. Read more in [#container-registry-storage-path](#container-registry-storage-path). |
| `issuer`  | This should be the same value as configured in Registry's `issuer`. Read the [token auth configuration documentation][token-config]. |

> **Note:** $GitSwarm$ does not ship with a Registry init file. Hence,
> [restarting $GitSwarm$][restart $GitSwarmPackage$] does not restart the Registry
> should you modify its settings. Read the upstream documentation on how to
> achieve that.

## Container Registry domain configuration

There are two ways you can configure the Registry's external domain.

- Either [use the existing $GitSwarm$ domain][existing-domain] where in
  that case the Registry will have to listen on a port and reuse
  $GitSwarm$'s TLS certificate,
- or [use a completely separate domain][new-domain] with a new TLS
  certificate for that domain.

Since the container Registry requires a TLS certificate, in the end it all
boils down to how easy or pricey is to get a new one.

Please take this into consideration before configuring the Container
Registry for the first time.

### Configure Container Registry under an existing $GitSwarm$ domain

If the Registry is configured to use the existing $GitSwarm$ domain, you
can expose the Registry on a port so that you can reuse the existing
$GitSwarm$ TLS certificate.

Assuming that the $GitSwarm$ domain is `https://gitswarm.example.com` and
the port the Registry is exposed to the outside world is `4567`, here is
what you need to set in `/etc/gitswarm/gitswarm.rb` or `gitlab.yml`, if you
are using a package installation or a source installation respectively.

---

**Package installations**

1.  Your `/etc/gitswarm/gitswarm.rb` should contain the Registry URL as
    well as the path to the existing TLS certificate and key used by
    $GitSwarm$:

    ```ruby
    registry_external_url 'https://gitswarm.example.com:4567'
    ```

    Note how the `registry_external_url` is listening on HTTPS under the
    existing $GitSwarm$ URL, but on a different port.

    If your TLS certificate is not in
    `/etc/gitswarm/ssl/gitswarm.example.com.crt` and key not in
    `/etc/gitswarm/ssl/gitswarm.example.com.key` uncomment the lines below:

    ```ruby
    registry_nginx['ssl_certificate'] = "/path/to/certificate.pem"
    registry_nginx['ssl_certificate_key'] = "/path/to/certificate.key"
    ```

1.  Save the file and [reconfigure $GitSwarm$] for the changes to take effect.

---

**Source Installations**

1.  Open `/home/git/gitlab/config/gitlab.yml`, find the `registry` entry
    and configure it with the following settings:

    ```
    registry:
      enabled: true
      host: gitswarm.example.com
      port: 4567
    ```

1.  Save the file and [restart $GitSwarm$] for the changes to take effect.
1.  Make the relevant changes in Nginx as well (domain, port, TLS
    certificates path).

---

Users should now be able to login to the Container Registry with their
$GitSwarm$ credentials using:

```bash
docker login gitswarm.example.com:4567
```

### Configure Container Registry under its own domain

If the Registry is configured to use its own domain, you will need a TLS
certificate for that specific domain (e.g., `registry.example.com`) or
maybe a wildcard certificate if hosted under a subdomain  of your existing
$GitSwarm$ domain (e.g., `registry.gitswarm.example.com`).

Let's assume that you want the container Registry to be accessible at
`https://registry.gitswarm.example.com`.

---

**Package installations**

1.  Place your TLS certificate and key in
    `/etc/gitswarm/ssl/registry.gitswarm.example.com.crt` and
    `/etc/gitswarm/ssl/registry.gitswarm.example.com.key` and make sure
    they have correct permissions:

    ```bash
    chmod 600 /etc/gitswarm/ssl/registry.gitswarm.example.com.*
    ```

1.  Once the TLS certificate is in place, edit `/etc/gitswarm/gitswarm.rb`
    with:

    ```ruby
    registry_external_url 'https://registry.gitswarm.example.com'
    ```

    Note how the `registry_external_url` is listening on HTTPS.

1.  Save the file and [reconfigure $GitSwarm$][] for the changes to take effect.

> **Note:** If you have a [wildcard certificate][], you need to specify the
> path to the certificate in addition to the URL, in this case
> `/etc/gitswarm/gitswarm.rb` will look like:
>
```ruby
registry_nginx['ssl_certificate'] = "/etc/gitswarm/ssl/certificate.pem"
registry_nginx['ssl_certificate_key'] = "/etc/gitswarm/ssl/certificate.key"
```

---

**Source Installations**

1.  Open `/home/git/gitlab/config/gitlab.yml`, find the `registry` entry
    and configure it with the following settings:

    ```
    registry:
      enabled: true
      host: registry.gitswarm.example.com
    ```

1.  Save the file and [restart $GitSwarm$] for the changes to take effect.
1.  Make the relevant changes in NGINX as well (domain, port, TLS
    certificates path).

---

Users should now be able to login to the Container Registry using their
$GitSwarm$ credentials:

```bash
docker login registry.gitswarm.example.com
```

## Disable Container Registry site-wide

> **Note:** Disabling the Registry in the Rails $GitSwarm$ application as
> set by the following steps, will not remove any existing Docker images.
> This is handled by the Registry application itself.

**Package installations**

1.  Open `/etc/gitswarm/gitswarm.rb` and set `registry['enable']` to
    `false`:

    ```ruby
    registry['enable'] = false
    ```

1.  Save the file and [reconfigure $GitSwarm$] for the changes to take
    effect.

---

**Source Installations**

1.  Open `/home/git/gitlab/config/gitlab.yml`, find the `registry` entry
    and set `enabled` to `false`:

    ```
    registry:
      enabled: false
    ```

1.  Save the file and [restart $GitSwarm$] for the changes to take effect.

## Disable Container Registry per project

If Registry is enabled in your $GitSwarm$ instance, but you don't need it
for your project, you can disable it from your project's settings. Read the
user guide on how to achieve that.

## Disable Container Registry for new projects site-wide

If the Container Registry is enabled, then it will be available on all new
projects. To disable this function and let the owners of a project to
enable the Container Registry by themselves, follow the steps below.

---

**Package installations**

1.  Edit `/etc/gitswarm/gitswarm.rb` and add the following line:

    ```ruby
    gitlab_rails['gitlab_default_projects_features_container_registry'] = false
    ```

1.  Save the file and [reconfigure $GitSwarm$] for the changes to take
    effect.

---

**Source Installations**

1.  Open `/home/git/gitlab/config/gitlab.yml`, find the
    `default_projects_features` entry and configure it so that
    `container_registry` is set to `false`:

    ```
    ## Default project features settings
    default_projects_features:
      issues: true
      merge_requests: true
      wiki: true
      snippets: false
      builds: true
      container_registry: false
    ```

1.  Save the file and [restart $GitSwarm$] for the changes to take effect.

## Container Registry storage path

To change the storage path where Docker images will be stored, follow the
steps below.

This path is accessible to:

- the user running the Container Registry daemon,
- the user running $GitSwarm$

> **Warning:** You should confirm that all $GitSwarm$, Registry and web server
> users have access to this directory.

---

**Package installations**

The default location where images are stored in package installations is
`/var/opt/gitswarm/gitlab-rails/shared/registry`. To change it:

1.  Edit `/etc/gitswarm/gitswarm.rb`:

    ```ruby
    gitlab_rails['registry_path'] = "/path/to/registry/storage"
    ```

1.  Save the file and [reconfigure $GitSwarm$] for the changes to take
    effect.

---

**Source Installations**

The default location where images are stored in source installations is
`/home/git/gitlab/shared/registry`. To change it:

1.  Open `/home/git/gitlab/config/gitlab.yml`, find the `registry` entry
    and change the `path` setting:

    ```
    registry:
      path: shared/registry
    ```

1.  Save the file and [restart $GitSwarm$] for the changes to take effect.

## Storage limitations

Currently, there is no storage limitation, which means a user can upload an
infinite amount of Docker images with arbitrary sizes. This setting will be
configurable in future releases.

[reconfigure $GitSwarmPackage$]: restart_gitlab.md#package-reconfigure
[restart $GitSwarmPackage$]: restart_gitlab.md#source-restart
[wildcard certificate]: https://en.wikipedia.org/wiki/Wildcard_certificate
[docker-insecure]: https://docs.docker.com/registry/insecure/
[registry-deploy]: https://docs.docker.com/registry/deploying/
[storage-config]: https://docs.docker.com/registry/configuration/#storage
[token-config]: https://docs.docker.com/registry/configuration/#token
[registry-ssl]: https://gitlab.com/gitlab-org/gitlab-ce/blob/master/lib/support/nginx/registry-ssl
[existing-domain]: #configure-container-registry-under-an-existing-$GitSwarmPackage$-domain
[new-domain]: #configure-container-registry-under-its-own-domain
