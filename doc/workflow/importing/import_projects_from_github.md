# Import your project from GitHub to GitLab

_**Note:** In order to enable the GitHub import setting, you should first
enable the [GitHub integration][gh-import] in your GitLab instance._

At its current state, GitHub importer can import:

- the repository description
- the git repository data
- the issues
- the pull requests
- the wiki pages

The importer page is visible when you [create a new project][new-project].
Click on the **GitHub** link and you will be redirected to GitHub for
permission to access your projects. After accepting, you'll be automatically
redirected to the importer.

![New project page on GitLab](img/import_projects_from_github_new_project_page.png)

---

While at the GitHub importer page, you can see the import statuses of your
GitHub projects. Those that are being imported will show a _started_ status,
those already imported will be green, whereas those that are not yet imported
have an **Import** button on the right side of the table. If you want, you can
import all your GitHub projects in one go by hitting **Import all projects**
in the upper left corner.

![GitHub importer page](img/import_projects_from_github_importer.png)

---

The importer will create any new namespaces if they don't exist or in the
case the namespace is taken, the project will be imported on the user's
namespace.

### Note

When you import your projects from GitHub, it is not possible to keep your
labels, milestones, and cross-repository pull requests. We are working on
improving this in the near future.

[gh-import]: ../../integration/github.md "GitHub integration"
[ee-gh]: http://doc.gitlab.com/ee/integration/github.html "GitHub integration for GitLab EE"
[new-project]: ../../gitlab-basics/create-project.md "How to create a new project in GitLab"
