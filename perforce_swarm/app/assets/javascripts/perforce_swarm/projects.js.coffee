disable = (elements, flag) ->
  $(elements).toggleClass('disabled', flag).attr('disabled', flag ? 'disabled' : '')

server_select     = '.git-fusion-import select#git_fusion_entry'
import_url_field  = 'input#project_import_url'
repo_name_select  = '.git-fusion-import select#git_fusion_repo_name'
auto_create_field = 'input#git_fusion_auto_create'
cancel_button     = '.git-fusion-import .mirror-cancel'

update_ui = () ->
  fusion_server_selected = $(server_select).length > 0 && !!$(server_select).find('option:selected').val()
  fusion_repo_selected = $(repo_name_select).length > 0 && !!$(repo_name_select).find('option:selected').val()
  has_import_url       = !!$(import_url_field).val()
  auto_create_repo     = $(auto_create_field).length > 0 && $(auto_create_field).is(':checked')
  # disable the external import section and buttons if we're doing mirroring
  disable('.external-import, .external-import a.btn, ' + import_url_field, fusion_server_selected)

  # if the user is doing an external import, disable mirroring controls
  disable('.git-fusion-import', has_import_url)
  disable('.mirror-existing, .mirror-existing select', auto_create_repo || has_import_url)
  disable('.mirror-new, .mirror-new input', fusion_repo_selected || has_import_url)

  $('.git-fusion-import').find(".js-toggle-content").toggle(fusion_server_selected)

$ ->
  update_ui();
  $('body').on 'input', import_url_field, (e) ->
    update_ui()

  $('body').on 'change', server_select, (e) ->
    update_ui()

  $('body').on 'change', repo_name_select, (e) ->
    update_ui()

  $('body').on 'change', auto_create_field, (e) ->
    update_ui()

  $(document).on 'click', cancel_button, (e) ->
    $(server_select).val('').trigger('change')
