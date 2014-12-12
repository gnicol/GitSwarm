# Wire up the namespace links in the title when it's a dropdown
# We need to do this because by default the dropdown eats the click events
$(document).on('click', '.navbar-gitlab .dropdown .title a', (e) -> e.stopPropagation())

getVisibilityIconClass = (visibilityLevel) ->
  levels = gon.visibility_levels
  switch visibilityLevel
    when levels.Private  then 'fa-lock'
    when levels.Internal then 'fa-shield'
    when levels.Public   then 'fa-globe'

$ ->
  # Only run on pages that have a top-navbar
  return unless $('.navbar-gitlab').length

  ###
  Add a list of 5 recently visited projects to the top level dashboard dropdown
  ###
  dashboardMenu     = $('.navbar-gitlab .dashboard-menu .dropdown-menu')
  visitedProjectIds = []
  visitedProjects   =
    (for visited in swarm.recentProjects.get()[0..4]
      visitedProjectIds.push(visited.project.id)
      visited.project)

  # Grab recently updated projects to fill up our menu if there aren't enough visited projects
  updatedProjects =
    (updated for updated in dashboardMenu.data('recent-updated') when visitedProjectIds.indexOf(updated.id) is -1)
  recentProjects  = visitedProjects.concat(updatedProjects)[0..4]

  # Add menu items for each recent project
  if recentProjects.length
    projectMenuItems = $('<li role="presentation" class="dropdown-header">Recent Projects</li>')
    for project in recentProjects
      slug             = (project.namespace?.path || '') + '/' + project.path
      namespace        = if project.namespace then (project.namespace.human_name + ' / ') else ''
      projectMenuItems = projectMenuItems.add("""
        <li role="menuitem">
          <a href="#{Routes.project_path(slug)}">
            <span class="recent-project-access-icon">
              <i class="fa #{getVisibilityIconClass[project.visibility_level]}"></i>
            </span>
            <span class="str-truncated">
              <span class="namespace">#{namespace}</span>
              <span class="project-name filter-title">#{project.name}</span>
            </span>
          </a>
        </li>
      """)
    projectMenuItems = projectMenuItems.add('<li role="presentation" class="divider"></li>')
    dashboardMenu.prepend(projectMenuItems)

  ###
  Move all subnav links, and some of the top nav
  links to a dropdown when viewport is small
  ###
  subnav   = $('nav.main-nav')
  username = gon.current_user_username

  # Create the new subnav dropdown menu, clone the exisitng subnav if available
  subnavMenu = if subnav.length then subnav.find('ul').clone() else $('<ul />')
  subnavMenu.addClass('dropdown-menu').attr('role', 'menu')

  # Define the top-level menus that we will add in
  menus = [
    {name: 'Help', path: -> Routes.help_path()}
    {name: 'Admin', disabled: gon.current_user_is_admin isnt true, path: -> Routes.admin_root_path()}
  ]

  # Append each menu to the subnav if it doesn't already exist
  for menu in menus when !menu.disabled and !subnav.find("li a[href='#{menu.path()}']").length
    subnavMenu.append("<li><a href=\"#{menu.path()}\">#{menu.name}</a></li>")

  # Create a dropdown menu that we will use for the subnav in mobile view
  subnavDropdown = $('<li class="dropdown navbar-right visible-xs" />')
  subnavDropdown.append("""
    <a class="dropdown-toggle" href="#" data-toggle="dropdown" aria-haspopup="true" aria-label="More Nav">
      <i class="fa fa-bars"></i>
    </a>
  """)
  subnavDropdown.append(subnavMenu)
  subnavDropdown.appendTo('.navbar-gitlab .navbar-nav')
