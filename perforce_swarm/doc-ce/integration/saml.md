# SAML OmniAuth Provider

GitSwarm can be configured to act as a SAML 2.0 Service Provider (SP). This
allows GitSwarm to consume assertions from a SAML 2.0 Identity Provider
(IdP) such as Microsoft ADFS to authenticate users. 

First configure SAML 2.0 support in GitSwarm, then register the GitSwarm
application in your SAML IdP:  

1.  Make sure GitSwarm is configured with HTTPS. See [Using
    HTTPS](../install/installation.md#using-https) for instructions.

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
        "name" => "saml",
         args: {
                 assertion_consumer_service_url: 'https://gitswarm.example.com/users/auth/saml/callback',
                 idp_cert_fingerprint: '43:51:43:a1:b5:fc:8b:b7:0a:3a:a9:b1:0f:66:73:a8',
                 idp_sso_target_url: 'https://login.example.com/idp',
                 issuer: 'https://gitswarm.example.com',
                 name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
               },
        "label" => "Company Login" # optional label for SAML login button, defaults to "Saml"
      }
    ]
    ```

1.  Change the value for 'assertion_consumer_service_url' to match the
    HTTPS endpoint of GitSwarm (append 'users/auth/saml/callback' to the
    HTTPS URL of your GitSwarm installation to generate the correct value). 

1.  Change the values of 'idp_cert_fingerprint', 'idp_sso_target_url',
    'name_identifier_format' to match your IdP. Check [the omniauth-saml
    documentation](https://github.com/PracticallyGreen/omniauth-saml) for
    details on these options.

1.  Change the value of 'issuer' to a unique name, which will identify the
    application to the IdP.

1.  Restart GitSwarm for the changes to take effect.

1.  Register the GitSwarm SP in your SAML 2.0 IdP, using the application
    name specified in 'issuer'. 

To ease configuration, most IdP accept a metadata URL for the application
to provide configuration information to the IdP. To build the metadata URL
for GitSwarm, append 'users/auth/saml/metadata' to the HTTPS URL of your
GitSwarm installation, for instance:

```
https://gitswarm.example.com/users/auth/saml/metadata
```

At a minimum the IdP *must* provide a claim containing the user's email
address, using claim name 'email' or 'mail'. The email will be used to
automatically generate the GitSwarm username. GitSwarm also uses claims
with name 'name', 'first_name', 'last_name' (see [the omniauth-saml
gem](https://github.com/PracticallyGreen/omniauth-saml/blob/master/lib/omniauth/strategies/saml.rb)
for supported claims).

On the sign in page there should now be a SAML button below the regular
sign in form. Click the icon to begin the authentication process. If
everything goes well, the user is returned to GitSwarm and is signed in.

## Troubleshooting

If you see a "500 error" in GitSwarm when you are redirected back from the
SAML sign in page, this likely indicates that GitSwarm could not get the
email address for the SAML user.

Make sure the IdP provides a claim containing the user's email address,
using claim name 'email' or 'mail'. The email will be used to automatically
generate the GitSwarm username.
