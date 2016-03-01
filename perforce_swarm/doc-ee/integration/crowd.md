# Crowd OmniAuth Provider

To enable the Crowd OmniAuth provider you must register your application
with Crowd. To configure Crowd integration you need an application name and
password.  

1.  On your GitSwarm EE server, open the configuration file.

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
        "name" => "crowd",
        "args" => { 
          "crowd_server_url" => "CROWD",
          "application_name" => "YOUR_APP_NAME",
          "application_password" => "YOUR_APP_PASSWORD"
        }
      }
    ]
    ```

1.  Change 'YOUR_APP_NAME' to the application name from Crowd applications
    page.

1.  Change 'YOUR_APP_PASSWORD' to the application password you've set.

1.  Save the configuration file.

1.  Restart GitSwarm EE for the changes to take effect.

On the sign in page there should now be a Crowd tab in the sign in form.
