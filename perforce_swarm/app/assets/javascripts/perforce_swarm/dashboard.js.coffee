$ ->
  $('.dismiss-version-check').on 'click', (e) ->
    path = '/'
    $.cookie('dismiss_version_check', 'true', { path: path })
    $(@).parents('.dismiss-version-check').remove()
    e.preventDefault()
