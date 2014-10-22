# Wire up the namespace links in the title when it's a dropdown
# We need to do this because by default the dropdown eats the click events
$(document).on('click', '.navbar-gitlab .dropdown .title a', (e) -> e.stopPropagation())

# Append links to the subnav bar when viewport is small
# These are links that normally live in the topnav but
# are instead shown in the subnav on small viewports
$ ->
  subnav   = $('nav.main-nav')
  username = gon.current_user_username

  # Only run on pages that have a top-navbar
  return unless $('.navbar-gitlab').length

  # Create a mobile navbar on pages that have a top-nav but not a sub-nav
  if !subnav.length
    subnav = $('<nav class="main-nav navbar-collapse collapse navless" />')
    subnav.append('<div class="container"><ul></ul></div>')
    subnav.insertAfter('.navbar-gitlab')

  # Define the menus that we will add in
  menus = [
    {name: 'Snippets', disabled: !username?, path: -> Routes.user_snippets_path(username)}
    {name: 'Help', path: -> Routes.help_path()}
    {name: 'Admin', disabled: gon.current_user_is_admin isnt true, path: -> Routes.admin_root_path()}
  ]

  # Append each menu to the subnav if it doesn't already exist
  subnavList = subnav.find('ul')
  for menu in menus when !menu.disabled and !subnav.find("li a[href='#{menu.path()}']").length
    subnavList.append("<li class=\"visible-xs\"><a href=\"#{menu.path()}\">#{menu.name}</a></li>")
