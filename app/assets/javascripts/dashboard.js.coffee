@Dashboard =
  init: ->
    this.initSearch()

  initSearch: ->
    @timer = null
    $("#project-filter-form-field").on('keyup', ->
      clearTimeout(@timer)
      @timer = setTimeout(Dashboard.filterResults, 500)
    )

  filterResults: =>
    $('.projects-list-holder').fadeTo(250, 0.5)

    form = null
    form = $("#project-filter-form")
    search = $("#project-filter-form-field").val()
    project_filter_url = form.attr('action') + '?' + form.serialize()

    $.ajax
      type: "GET"
      url: form.attr('action')
      data: form.serialize()
      complete: ->
        $('.projects-list-holder').fadeTo(250, 1)
      success: (data) ->
        $('div.projects-list-holder').replaceWith(data.html)
        # Change url so if user reload a page - search results are saved
        history.replaceState {page: project_filter_url}, document.title, project_filter_url
      dataType: "json"
