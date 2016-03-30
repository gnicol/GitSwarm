# Integrate your server with GitLab.com

Import projects from GitLab.com and login to your GitSwarm instance with
your GitLab.com account.

To enable the GitLab.com OmniAuth provider you must register your
application with GitLab.com. GitLab.com generates an application ID and
secret key for you to use.

1.  Sign in to GitLab.com

1.  Navigate to your profile settings.

1.  Select "Applications" in the left menu.

1.  Select "New application".

1.  Provide the required details.
    - Name: This can be anything. Consider something like
      "\<Organization\>'s GitSwarm" or "\<Your Name\>'s GitSwarm" or
      something else descriptive.
    - Redirect URI:

    ```
    http://your-gitswarm.example.com/import/gitlab/callback
    http://your-gitswarm.example.com/users/auth/gitlab/callback
    ```

    The first link is required for the importer and second for the
    authorization.

1.  Select "Submit".

1.  You should now see a Client ID and Client Secret near the top right of
    the page (see screenshot). Keep this page open as you continue
    configuration. 
    ![GitLab app](gitlab_app.png)

1.  On your GitSwarm server, open the configuration file.


    ```bash
    sudo editor /etc/gitswarm/gitswarm.rb
    ```

1.  See [Initial OmniAuth
    Configuration](omniauth.md#initial-omniauth-configuration) for initial
    settings.

1.  Add the provider configuration:

    ```ruby
    gitlab_rails['omniauth_providers'] = [
      {
        "name" => "gitlab",
        "app_id" => "YOUR_APP_ID",
        "app_secret" => "YOUR_APP_SECRET",
        "args" => { "scope" => "api" }
      }
    ]
    ```

1.  Change 'YOUR_APP_ID' to the Application ID from the GitLab.com
    application page.

1.  Change 'YOUR_APP_SECRET' to the secret from the GitLab.com application
    page.

1.  Save the configuration file.

1.  Restart GitSwarm for the changes to take effect.

On the sign in page, there should now be a GitLab.com icon below the
regular sign in form. Click the icon to begin the authentication process.
GitLab.com asks the user to sign in and authorize GitSwarm. If everything
goes well, the user is returned to your GitSwarm instance and is signed in.
