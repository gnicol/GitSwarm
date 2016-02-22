# Microsoft Azure OAuth2 OmniAuth Provider

To enable the Microsoft Azure OAuth2 OmniAuth provider you must register
your application with Azure. Azure will generate a client ID and secret key
for you to use.

1.  Sign in to the [Azure Management
    Portal](https://manage.windowsazure.com>).

1.  Select "Active Directory" on the left and choose the directory you want
    to use to register GitSwarm.

1.  Select "Applications" at the top bar and click the "Add" button the
    bottom.

1.  Select "Add an application my organization is developing".

1.  Provide the project information and click the "Next" button.
    - Name: 'GitSwarm' works just fine here.
    - Type: 'WEB APPLICATION AND/OR WEB API'

1.  On the "App properties" page enter the needed URI's and click the
    "Complete" button.

    - SIGN-IN URL: Enter the URL of your GitSwarm installation (e.g
      'https://gitswarm.mycompany.com/')
    - APP ID URI: Enter the endpoint URL for Microsoft to use, just has to
      be unique (e.g 'https://mycompany.onmicrosoft.com/gitswarm')

1. Select "Configure" in the top menu.

1. Add a "Reply URL" pointing to the Azure OAuth callback of your GitSwarm
   installation (e.g.
   https://gitswarm.mycompany.com/users/auth/azure_oauth2/callback).

1. Create a "Client secret" by selecting a duration, the secret will be
   generated as soon as you click the "Save" button in the bottom menu..

1. Note the "CLIENT ID" and the "CLIENT SECRET".

1. Select "View endpoints" from the bottom menu.

1. You will see lots of endpoint URLs in the form
   'https://login.microsoftonline.com/TENANT ID/...', note down the TENANT
   ID part of one of those endpoints.

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
        "name" => "azure_oauth2",
        "args" => {
          "client_id" => "CLIENT ID",
          "client_secret" => "CLIENT SECRET",
          "tenant_id" => "TENANT ID",
        }
      }
    ]
    ```

1.  Replace 'CLIENT ID', 'CLIENT SECRET' and 'TENANT ID' with the values
    you got above.

1.  Save the configuration file.

1.  Restart GitSwarm for the changes to take effect.

On the sign in page there should now be a Microsoft icon below the regular
sign in form. Click the icon to begin the authentication process. Microsoft
asks the user to sign in and authorize the GitSwarm application. If
everything goes well, the user is returned to GitSwarm and is signed in.
