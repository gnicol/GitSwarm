# Integrate your server with GitHub

Import projects from GitHub and login to your GitSwarm instance with your
GitHub account.

To enable the GitHub OmniAuth provider you must register your application
with GitHub. GitHub will generate an application ID and secret key for you
to use.

1.  Sign in to GitHub.

1.  Navigate to your individual user settings or an organization's
    settings, depending on how you want the application registered. It does
    not matter if the application is registered as an individual or an
    organization - that is entirely up to you.

1.  Select "Applications" in the left menu.

1.  Select "Register new application".

1.  Provide the required details.
    - Application name: This can be anything. Consider something like
      "\<Organization\>'s GitSwarm" or "\<Your Name\>'s GitSwarm" or
      something else descriptive.
    - Homepage URL: The URL to your GitSwarm installation.
      `https://gitswarm.company.com`
    - Application description: Fill this in if you wish.
    - Authorization callback URL: `https://gitswarm.company.com/`
1.  Select "Register application".

1.  You should now see a Client ID and Client Secret near the top right of the page (see screenshot). 
    Keep this page open as you continue configuration.
    ![GitHub app](github_app.png)

1.  On your GitSwarm server, open the configuration file.

    ```sh
sudo editor /etc/gitswarm/gitswarm.rb
    ```

1.  See [Initial OmniAuth
    Configuration](omniauth.md#initial-omniauth-configuration) for initial
    settings.

1.  Add the provider configuration:

    ```ruby
    gitlab_rails['omniauth_providers'] = [
      {
        "name"       => "github",
        "app_id"     => "YOUR_APP_ID",
        "app_secret" => "YOUR_APP_SECRET",
        "url"        => "https://github.com/",
        "args"       => { "scope" => "user:email" }
      }
    ]
    ```

1.  Change `YOUR_APP_ID` to the client ID from the GitHub application page
    from step 7.

1.  Change `YOUR_APP_SECRET` to the client secret from the GitHub
    application page  from step 7.

1.  Save the configuration file.

1.  Restart GitSwarm for the changes to take effect.

On the sign in page there should now be a GitHub icon below the regular
sign in form. Click the icon to begin the authentication process. GitHub
will ask the user to sign in and authorize the GitSwarm application. If
everything goes well the user will be returned to GitSwarm and will be
signed in.
