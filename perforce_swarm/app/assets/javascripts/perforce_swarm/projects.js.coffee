disable = (elements, flag) ->
  $(elements).toggleClass('disabled', flag).attr('disabled', flag ? 'disabled' : '')

repo_name_select  = '.git-fusion-import select#git_fusion_repo_name'
import_url_field  = 'input#project_import_url'
auto_create_field = 'input#git_fusion_auto_create'

update_ui = () ->
  fusion_repo_selected = $(repo_name_select).length > 0 && !!$(repo_name_select).find('option:selected').val()
  has_import_url       = !!$(import_url_field).val()
  auto_create_repo     = $(auto_create_field).length > 0 && $(auto_create_field).is(':checked')
  # disable the external import section and buttons if we're doing mirroring
  disable('.external-import, .external-import a.btn, ' + import_url_field, fusion_repo_selected || auto_create_repo)

  # if the user is doing an external import, disable mirroring controls
  disable('.git-fusion-import', has_import_url)
  disable('.mirror-existing, .mirror-existing select', auto_create_repo || has_import_url)
  disable('.mirror-new, .mirror-new input', fusion_repo_selected || has_import_url)

$ ->
  update_ui();
  $('body').on 'input', import_url_field, (e) ->
    update_ui()

  $('body').on 'change', repo_name_select, (e) ->
    update_ui()

  $('body').on 'change', auto_create_field, (e) ->
    update_ui()
