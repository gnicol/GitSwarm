class @GitFusionProject
  server_select_selector:     'select#git_fusion_entry'
  import_url_selector:        'input#project_import_url'
  repo_name_selector:         'select#git_fusion_repo_name'
  original_settings_selector: '#original-git-fusion-settings'
  disabled_selector:          'input#git_fusion_auto_create_nil'
  auto_create_selector:       'input#git_fusion_auto_create_true'
  repo_import_selector:       'input#git_fusion_auto_create_false'
  repo_contents:               null

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

    this.$el.on 'select2-open', @repo_name_selector, (e) =>
      this.$(@repo_import_selector).prop('checked', true)

    this.$el.on 'change', "#{@disabled_selector}, #{@auto_create_selector}, #{@repo_import_selector}", (e) =>
      $(@original_settings_selector).remove()
      @update_ui()

    $(document).on 'input', @import_url_selector, (e) =>
      @update_ui()

  # Local jQuery finder
  $: (selector) ->
    this.$el.find(selector)

  disable: (elements, flag) ->
    flag = !!flag
    $(elements).not('[data-keep-disabled=true]').toggleClass('disabled', flag).prop('disabled', flag)

  update_ui: ->
    auto_create_selected = fusion_repo_selected = disabled_selector = false
    has_import_url       = !!$(@import_url_selector).val()

    # re-populate auto create selection and repo name
    if ($(@original_settings_selector).length)
      original_auto_create = $(@original_settings_selector).data('auto-create')
      $('input#git_fusion_auto_create_' + original_auto_create).prop('checked', true)

    if (this.$(@auto_create_selector).length)
      disabled_selector    = this.$(@disabled_selector).is(':checked')
      auto_create_selected = this.$(@auto_create_selector).is(':checked')
      fusion_repo_selected = this.$(@repo_import_selector).is(':checked') &&
        !!this.$(@repo_name_selector).find('option:selected').val()

    # disable the external import section and buttons if we're doing mirroring
    @disable('.external-import, .external-import a.btn, ' + @import_url_selector, fusion_repo_selected || auto_create_selected)

    # if the user is doing an external import, disable mirroring controls
    @disable('.git-fusion-import, .git-fusion-import select, .git-fusion-import input', has_import_url)

    # clear the repo list when mirror existing is not selected
    if auto_create_selected || disabled_selector
      this.$(@repo_name_selector).val('').select2()

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

      error: =>
        if this.$(@server_select_selector).val() == server_id
          @set_content(
            '<div class="git-fusion-import-data">' +
              '<div class="description slead"><h4>Error</h4>Refresh and try again</div>' +
            '</div>'
          )
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
