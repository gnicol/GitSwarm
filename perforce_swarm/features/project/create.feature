Feature: Project Create

  # There are tests for project creation through the API in /spec/requests/api/projects_spec.rb

  ###############
  # Access Points
  ###############

  Scenario: As an admin, I click button "New Project" from the admin page
    Given ...

  Scenario: As a user, I click button "New Project" from the dashboard page
    # Automated (in a sense) in features/dashboard/dashboard.feature; Scenario: I should see projects list
    # There is a step in this scenario that asserts if the "New Project" link exists
    # User must have a project to see this button - otherwise, the "Welcome to GitLab" page is displayed
    Given ...

  Scenario: As a new user, I click button "New Project" from the "Welcome to GitLab" dashboard page
    # If a user has no projects (is new), and can create projects the dashboard page has a "New Project" button
    # The front page will display how many projects they can create
    Given ...

  Scenario: As a new user who cannot create projects, I do not see "New Project" button on the "Welcome to GitLab" dashboard page
    # cannot create projects == project limit of 0
    # message on front page reads: You don't have access to any projects right now.
    # The user can still attempt to create a project from the my projects page
    Given ...

  Scenario: As a user, I click button "New Project" from my projects page
    # Automated in features/project/create.feature; Scenario: User create a project
    Given ...

  Scenario: As a user, I click button "New Project" from the group dashboard page
    Given ...

  ###############
  # Project Limit
  ###############

  Scenario: As a user who cannot create projects, I receive an error when I attempt to create a new project
    # Automated in spec/models/project_spec.rb; it 'should not allow new projects beyond user limits'
    # cannot create projects == project limit of 0
    # error message: Limit reached Your project limit is 0 projects! Please contact your administrator to increase it
    Given ...

  ##############
  # Project Path
  ##############

  # Form Validation? There are unit tests but should user experience functional tests be added?

  Scenario: As a user, I cannot create a project with a blank path
    # Error message: "name can't be blank" --- also true with a path made up of whitespace
    Given ...

  Scenario: As a user, I can create a project with the path "12345"
    Given ...

  Scenario: As a user, I can create a project with the path "New_Project.1"
    Given ...

  Scenario: As a user, I can create a project with the path "NewProject"
    Given ...

  Scenario: As a user, I can create a project with the path "........"
    # This is possible to do (and you can push and clone using http) but the error messages indicate that you shoudn't be able to
    Given ...

  Scenario: As a user, I can create a project with the path "_______"
    Given ...

  Scenario: As a user, I can create a project with the path ".newproject"
    # Bug? Project paths can begin with a period even though this error message says that they can't. Can push and clone (http) from this repo
    # Although the repo is in a . directory now
    Given ...

  Scenario: As a user, I receive an error message if I attempt to create a project with a special character in the path
    # Error message: Name can contain only letters, digits, '_', '-' and '.' and space. It must start with letter, digit or '_'.
    Given ...

  Scenario: As a user, I receive an error message if I attempt to create a project with a path that begins with a dash
    # Error message: Name can contain only letters, digits, '_', '-' and '.' and space. It must start with letter, digit or '_'.
    Given ...

  Scenario: As a user, I receive an error message if I attempt to create a project with a path that ends with ".git"
    # Error message: Path can contain only letters, digits, '_', '-' and '.'. Cannot start with '-' or end in '.git'
    Given ...

  Scenario: As a user, I receive an error message if I attempt to create a project with a path that ends/begins/ with a space
    # Error message: Name can contain only letters, digits, '_', '-' and '.' and space. It must start with letter, digit or '_'.
    Given ...

  Scenario: As a user, I receive an error message if I attempt to create a project with a path that has a space in it
    # Despite the error message that indicates you can have a space, this is not allowed.
    # Error message: Path can contain only letters, digits, '_', '-' and '.'. Cannot start with '-' or end in '.git'
    Given ...


  ###########
  # Namespace
  ###########

  # There are unit tests that confirm that the namespace can be a user namespace or a group namespace at
  # spec/services/projects/create_service_spec.rb

  Scenario: As a user, I should see only the namespaces that I have access to in the dropdown.
    # A user will have access to their own namespace and any group that they are a master or owner of
    # The dropdown will not appear unless you have access to multiple namespaces.
    Given ...

  Scenario: As a user, I should not see group namespaces that I am not a master or owner of in the dropdown.
    Given ...

  ######################
  # Existing Repo Import
  ######################

  Scenario: As a user, I should be able to import an existing repo
    Given ...

  ###############
  # Empty Project
  ###############

  Scenario: As a user, I can create a new empty project.
    # Automated in features/project/create.feature; Scenario: User create a project
    # Fills in the path with "Empty" and then uses all the defaults for the rest
    Given ...

  ############
  # Visibility
  ############

  # Note: default is set to private

  Scenario: As a user, I can create a private project.
    Given ...

  Scenario: As a user, I can create an internal project.
    Given ...

  Scenario: As a user, I can create a public project.
    Given ...