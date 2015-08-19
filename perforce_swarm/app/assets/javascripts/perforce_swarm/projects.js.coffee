class @GitFusionImportConfig
  server_select_selector: 'select#git_fusion_entry'
  import_url_selector:    'input#project_import_url'
  repo_name_selector:     'select#git_fusion_repo_name'
  auto_create_selector:   'input#git_fusion_auto_create_true'
  repo_import_selector:   'input#git_fusion_auto_create_false'
  repo_contents:          null

  constructor: (@opts) ->
    this.$el       = $('.git-fusion-import')
    @repo_contents = {}
    @load_content(this.$(@server_select_selector).val()) if this.$(@server_select_selector).val()

    this.$el.on 'input', @import_url_selector, (e) =>
      @update_ui()

    this.$el.on 'change', @server_select_selector, (e) =>
      server = $(e.currentTarget)
      @load_content(server.val())

    this.$el.on 'change', @repo_name_selector, (e) =>
      @update_ui()

    this.$el.on 'change', "#{@auto_create_selector}, #{@repo_import_selector}", (e) =>
        @update_ui()

  # Local jQuery finder
  $: (selector) ->
    this.$el.find(selector)

  disable: (elements, flag) ->
    flag = !!flag
    $(elements).toggleClass('disabled', flag).prop('disabled', flag)

  update_ui: ->
    fusion_server_selected = this.$(@server_select_selector).length > 0 && !!this.$(@server_select_selector).find('option:selected').val()
    fusion_repo_selected   = this.$(@repo_name_selector).length > 0 && !!this.$(@repo_name_selector).find('option:selected').val()
    has_import_url         = !!this.$(@import_url_selector).val()
    auto_create_repo       = this.$(@auto_create_selector).length > 0 && this.$(@auto_create_selector).is(':checked')
    # disable the external import section and buttons if we're doing mirroring
    @disable('.external-import, .external-import a.btn, ' + @import_url_selector, fusion_server_selected)

    # if the user is doing an external import, disable mirroring controls
    @disable('.git-fusion-import, .git-fusion-import select, .git-fusion-import input', has_import_url)

    @disable(@repo_name_selector, has_import_url || auto_create_repo)

  load_content: (server_id) ->
    @set_content('<div class="git-fusion-import-data"></div>')

    return @set_content(@repo_contents[server_id]) if @repo_contents[server_id]

    url = '/import/git_fusion/configure.json'
    url = gon.relative_url_root + url if gon.relative_url_root?
    $.ajax(url, {
      type: 'GET',
      dataType: 'json',
      data: {fusion_server: server_id}
      success: (data) =>
        @repo_contents[server_id] = data.html
        if this.$("#{@server_select_selector} option:selected").val() == server_id
          @set_content(@repo_contents[server_id])
      beforeSend: =>
        @set_content(
          '<div class="git-fusion-import-data">' +
            '<div class="loading"><p><i class="fa fa-spinner fa-spin"></i> Loading</p></div>' +
          '</div>'
        )
    })

  set_content: (content) ->
    this.$('.git-fusion-import-data').replaceWith(content)
    this.$('.git-fusion-import-data select.select2').select2({
      width: 'resolve',
      dropdownAutoWidth: true
    });
    @update_ui()
