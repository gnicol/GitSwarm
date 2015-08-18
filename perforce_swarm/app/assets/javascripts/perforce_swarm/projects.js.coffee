disable = (elements, flag) ->
  flag = !!flag
  $(elements).toggleClass('disabled', flag).prop('disabled', flag)

server_select     = '.git-fusion-import select#git_fusion_entry'
import_url_field  = 'input#project_import_url'
repo_name_select  = '.git-fusion-import select#git_fusion_repo_name'
auto_create_field  = 'input#git_fusion_auto_create_true'
repo_import_field  = 'input#git_fusion_auto_create_false'
cancel_button     = '.git-fusion-import .mirror-cancel'
repo_options      = {}

update_repo_list = (server_id) ->
  if repo_options[server_id]
    update_repo_list_options(repo_options[server_id])
    return

  url = '/import/git_fusion/repos.json'
  url = gon.relative_url_root + url if gon.relative_url_root?
  $.ajax(url, {
    type: 'GET',
    dataType: 'json',
    data: {fusion_server: server_id}
    success: (data) ->
      repo_options[server_id] = data.html
    beforeSend: ->
      $(repo_name_select).html('<option class="loading" selected=true>Loading...</option>')
      disable_repo_list(true)
      $(repo_name_select).trigger('change')
    complete: ->
      if $(server_select).find('option:selected').val() == server_id
        update_repo_list_options(repo_options[server_id] || '')
  })

update_repo_list_options = (options) ->
  repo_select = $(repo_name_select)
  repo_select.html(options)
  repo_select.first().prop('selected', true)
  disable_repo_list(false)
  repo_select.trigger('change')

disable_repo_list = (set) ->
  has_import_url   = !!$(import_url_field).val()
  auto_create_repo = $(auto_create_field).length > 0 && $(auto_create_field).is(':checked')
  still_loading    = $(repo_name_select).find('.loading').length > 0

  # Don't re-enable if the field is still meant to be disabled
  if !set && (has_import_url || auto_create_repo || still_loading)
    set = true

  disable(repo_name_select, set)

update_ui = () ->
  fusion_server_selected = $(server_select).length > 0 && !!$(server_select).find('option:selected').val()
  fusion_repo_selected = $(repo_name_select).length > 0 && !!$(repo_name_select).find('option:selected').val()
  has_import_url       = !!$(import_url_field).val()
  auto_create_repo     = $(auto_create_field).length > 0 && $(auto_create_field).is(':checked')
  # disable the external import section and buttons if we're doing mirroring
  disable('.external-import, .external-import a.btn, ' + import_url_field, fusion_server_selected)

  # if the user is doing an external import, disable mirroring controls
  disable('.git-fusion-import, .git-fusion-import select, .git-fusion-import input', has_import_url)

  disable_repo_list(auto_create_repo)

  $('.git-fusion-import').find(".js-toggle-content").toggle(fusion_server_selected)

$ ->
  update_ui()
  $('body').on 'input', import_url_field, (e) ->
    update_ui()

  $('body').on 'change', server_select, (e) ->
    server = $(this)
    $(repo_name_select).html('')
    update_ui()
    update_repo_list(server.val()) if !!server.val()

  $('body').on 'change', repo_name_select, (e) ->
    update_ui()

  $('body').on 'change', "#{auto_create_field}, #{repo_import_field}", (e) ->
    update_ui()

  $(document).on 'click', cancel_button, (e) ->
    $(server_select).val('').trigger('change')
