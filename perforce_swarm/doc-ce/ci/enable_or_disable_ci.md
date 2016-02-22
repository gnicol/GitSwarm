## Enable or disable GitLab CI

_To effectively use GitLab CI, you need a valid
[`.gitlab-ci.yml`](yaml/README.md) file present at the root directory of
your project and a [runner](runners/README.md) properly set up. You can
read our [quick start guide](quick_start/README.md) to get you started._

If you are using an external CI server like Jenkins or Drone CI, it is
advised to disable GitLab CI in order to not have any conflicts with the
commits status API.

---

As of GitSwarm 2015.4, GitLab CI is mainly exposed via the `/builds` page
of a project. Disabling GitLab CI in a project does not delete any previous
builds. In fact, the `/builds` page can still be accessed, although it's
hidden from the left sidebar menu.

GitLab CI is enabled by default on new installations and can be disabled
either individually under each project's settings, or site-wide by
modifying the settings in `gitlab.yml` and `gitlab.rb` for source and
Omnibus installations respectively.

### Per-project user setting

The setting to enable or disable GitLab CI can be found with the name
**Builds** under the **Features** area of a project's settings along with
**Issues**, **Merge Requests**, **Wiki** and **Snippets**. Select or
deselect the checkbox and hit **Save** for the settings to take effect.

![Features settings](img/features_settings.png)

---

### Site-wide administrator setting

You can disable GitLab CI site-wide, by modifying the settings in
`/etc/gitswarm/gitswarm.rb`.

Two things to note:

1. Disabling GitLab CI affects only newly-created projects. Projects that
   had it enabled prior to this modification, continue to work as before.
1. Even if you disable GitLab CI, users are still able to enable it in
   the project's settings.

---

Edit `/etc/gitswarm/gitswarm.rb` and add the line:

```
gitlab-rails['gitlab_default_projects_features_builds'] = false
```

Save the file and reconfigure GitSwarm: `sudo gitswarm-ctl reconfigure`.
