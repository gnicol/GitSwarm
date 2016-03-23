# GitSwarm Integration

GitSwarm integrates with multiple third-party services to allow external
issue trackers and external authentication.

See the documentation below for details on how to configure these services.

- [Jira](jira.md) Integrate with the JIRA issue tracker
- [External issue tracker](external-issue-tracker.md) Redmine, JIRA, etc.
- [LDAP](ldap.md) Set up sign in via LDAP
- [Jenkins](jenkins.md) Integrate with the Jenkins CI
- [OmniAuth](omniauth.md) Sign in via Twitter, GitHub, GitLab, and Google
  via OAuth.
- [SAML](saml.md) Configure GitSwarm as a SAML 2.0 Service Provider
- [CAS](cas.md) Configure GitSwarm to sign in using CAS
- [Slack](slack.md) Integrate with the Slack chat service
- [OAuth2 provider](oauth_provider.md) OAuth2 application creation
- [Gmail actions buttons](gmail_action_buttons_for_gitlab.md) Adds GitSwarm
  actions to messages
- [reCAPTCHA](recaptcha.md) Configure GitSwarm to use Google reCAPTCHA for
  new users

## Project services

Integration with services such as Campfire, Flowdock, Gemnasium, HipChat,
Pivotal Tracker, and Slack are available in the form of a [Project
Service]. You can find these within GitSwarm in the Services page under
Project Settings if you are at least a master on the project.  Project
Services are a bit like plugins in that they allow a lot of freedom in
adding functionality to GitSwarm. For example there is also a service that
can send an email every time someone pushes new commits.

Because GitSwarm is open source we can ship with the code and tests for all
plugins. This allows the community to keep the plugins up to date so that
they always work in newer GitSwarm versions.

For an overview of what projects services are available without logging in,
please see the [project_services directory][projects-code].

[Project Service]: ../project_services/project_services.md
[projects-code]: https://gitlab.com/gitlab-org/gitlab-ce/tree/master/app/models/project_services