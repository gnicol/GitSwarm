$ ->
  $('.dismiss-version-check').on 'click', (e) ->
    path = '/'
    $.cookie('dismiss_version_check', 'true', { path: path })
    $(@).parents('.version-check-status').remove()
    e.preventDefault()
  $('.alert-link').bind 'ajax:success', (event, data) ->
    $('.version-check-status').hide()
    new Flash(data.message, 'notice')
