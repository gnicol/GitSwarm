$ ->
  $("body").on "click", ".helix-toggle", (e) ->
    $(@).parents().find(".helix-toggle-content").toggle()
    e.preventDefault()
