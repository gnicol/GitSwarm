# Facebook OAuth2 OmniAuth Provider

To enable the Facebook OmniAuth provider, you must register your application
with Facebook. Facebook will generate an app ID and secret key for you to
use.

1.  Sign in to the [Facebook Developer
    Platform](https://developers.facebook.com/).

1.  Choose "My Apps" &gt; "Add a New App".

1.  Select the type "Website".

1.  Enter a name for your app. This can be anything. Consider something
    like "\<Organization\>'s GitSwarm" or "\<Your Name\>'s GitSwarm" or
    something else descriptive.

1.  Choose "Create New Facebook App ID".

1.  Select a Category, for example "Productivity".

1.  Choose "Create App ID".

1.  Enter the address of your GitSwarm installation at the bottom of the
    package:

    ![Facebook Website URL](facebook_website_url.png)

1.  Choose "Next".

1.  Choose "Skip Quick Start" in the upper right corner.

1.  Choose "Settings" in the menu on the left.

1.  Fill in a contact email for your app:

    ![Facebook App Settings](facebook_app_settings.png)

1.  Choose "Save Changes".

1.  Choose "Status & Review" in the menu on the left.

1.  Change the switch on the right from "No" to "Yes".

1.  Choose "Confirm" when prompted to make the app public.

1.  Choose "Dashboard" in the menu on the left.

1.  Choose "Show" next to the hidden "App Secret".

1.  You should now see an app key and app secret (see screenshot). Keep
    this page open as you continue configuration.

    ![Facebook API Keys](facebook_api_keys.png)

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
        "name" => "facebook",
        "app_id" => "YOUR_APP_ID",
        "app_secret" => "YOUR_APP_SECRET"
      }
    ]
    ```

1.  Change 'YOUR_APP_ID' to the API key from Facebook page in step 10.

1.  Change 'YOUR_APP_SECRET' to the API secret from the Facebook page in
    step 10.

1.  Save the configuration file.

1.  Restart GitSwarm for the changes to take effect.

On the sign in page there should now be a Facebook icon below the regular
sign in form. Click the icon to begin the authentication process. Facebook
asks the user to sign in and authorize GitSwarm. If everything goes well,
the user is returned to GitSwarm and is signed in.
