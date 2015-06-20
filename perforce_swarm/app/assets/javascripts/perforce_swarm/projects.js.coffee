$ ->
  $('body').on 'click', '.helix-toggle', (e) ->
    $(@).parents().find('.helix-toggle-content').toggle()
    e.preventDefault()

  $('body').on 'change', 'select#repo_id', (e) ->
    if $(@).find('option:selected').text() != ''
      $(@).parents().find('.external-import, .external-import > .centered-buttons > a.btn').addClass('disabled')
    else
      $(@).parents().find('.external-import, .external-import > .centered-buttons > a.btn').removeClass('disabled')
    e.preventDefault()