# Wire up the namespace links in the title when it's a dropdown
# We need to do this because by default the dropdown eats the click events
$(document).on('click', '.navbar-gitlab .dropdown .title a', (e) -> e.stopPropagation())

# Move all subnav links, and some of the top nav
# links to a dropdown when viewport is small
$ ->
  subnav   = $('nav.main-nav')
  username = gon.current_user_username

  # Only run on pages that have a top-navbar
  return unless $('.navbar-gitlab').length

  # Create the new subnav dropdown menu, clone the exisitng subnav if available
  subnavMenu = if subnav.length then subnav.find('ul').clone() else $('<ul />')
  subnavMenu.addClass('dropdown-menu').attr('role', 'menu')

  # Define the top-level menus that we will add in
  menus = [
    {name: 'Snippets', disabled: !username?, path: -> Routes.user_snippets_path(username)}
    {name: 'Help', path: -> Routes.help_path()}
    {name: 'Admin', disabled: gon.current_user_is_admin isnt true, path: -> Routes.admin_root_path()}
  ]

  # Append each menu to the subnav if it doesn't already exist
  for menu in menus when !menu.disabled and !subnav.find("li a[href='#{menu.path()}']").length
    subnavMenu.append("<li><a href=\"#{menu.path()}\">#{menu.name}</a></li>")

  # Create a dropdown menu that we will use for the subnav in mobile view
  subnavDropdown = $('<li class="dropdown navbar-right visible-xs" />')
  subnavDropdown.append(
    '<a class="dropdown-toggle" href="#" data-toggle="dropdown" aria-haspopup="true" aria-label="More Nav">' +
      '<i class="fa fa-bars"></i>' +
    '</a>'
  )
  subnavDropdown.append(subnavMenu)
  subnavDropdown.appendTo('.navbar-gitlab .navbar-nav')
