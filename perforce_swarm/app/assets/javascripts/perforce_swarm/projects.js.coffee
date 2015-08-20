class @GitFusionProject
  server_select_selector: 'select#git_fusion_entry'
  import_url_selector:    'input#project_import_url'
  repo_name_selector:     'select#git_fusion_repo_name'
  repo_contents:          null

  constructor: (@opts) ->
    this.$el       = $('.git-fusion-import')
    @repo_contents = {}

    # Load content right away if we already have a server_id selected
    @load_content(this.$(@server_select_selector).val()) if this.$(@server_select_selector).val()

    # Wire up listeners
    this.$el.on 'change', @server_select_selector, (e) =>
      server = $(e.currentTarget)
      @load_content(server.val())

    this.$el.on 'change', @repo_name_selector, (e) =>
      @update_ui()

    $(document).on 'input', @import_url_selector, (e) =>
      @update_ui()

  # Local jQuery finder
  $: (selector) ->
    this.$el.find(selector)

  disable: (elements, flag) ->
    flag = !!flag
    $(elements).toggleClass('disabled', flag).prop('disabled', flag)

  update_ui: ->
    fusion_repo_selected   = this.$(@repo_name_selector).length > 0 && !!this.$(@repo_name_selector).find('option:selected').val()
    has_import_url         = !!$(@import_url_selector).val()

    # disable the external import section and buttons if we're doing mirroring
    @disable('.external-import, .external-import a.btn, ' + @import_url_selector, fusion_repo_selected)

    # if the user is doing an external import, disable mirroring controls
    @disable('.git-fusion-import, .git-fusion-import select, .git-fusion-import input', has_import_url)

  load_content: (server_id) ->
    # Clear out pre-existing content right away
    @set_content('<div class="git-fusion-import-data"></div>')

    # Set the new content if we already have it loaded
    return @set_content(@repo_contents[server_id]) if @repo_contents[server_id]

    # Fetch the server configuration if we don't already have it loaded
    url = '/gitswarm/git_fusion/new_project.json'
    url = gon.relative_url_root + url if gon.relative_url_root?
    $.ajax(url, {
      type: 'GET',
      dataType: 'json',
      data: {fusion_server: server_id}
      success: (data) =>
        # Store it so we don't fetch it again
        @repo_contents[server_id] = data.html
        # Only update the list if our server_id is still selected
        if this.$(@server_select_selector).val() == server_id
          @set_content(@repo_contents[server_id])
      beforeSend: =>
        # Add loading spinner
        @set_content(
          '<div class="git-fusion-import-data">' +
            '<div class="loading"><p><i class="fa fa-spinner fa-spin"></i> Loading</p></div>' +
          '</div>'
        )
    })

  set_content: (content) ->
    this.$('.git-fusion-import-data').replaceWith(content)
    # Wire up the select dropdown, as the jQuery onLoad listeners have already fired
    this.$('.git-fusion-import-data select.select2').select2({
      width: 'resolve',
      dropdownAutoWidth: true
    })
    @update_ui()
