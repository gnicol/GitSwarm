disable = (elements, flag) ->
  $(elements).toggleClass('disabled', flag).attr('disabled', flag ? 'disabled' : '')

repo_name_select = '.git-fusion-import select#git_fusion_repo_name'
import_url_field = 'input#project_import_url'

update_ui = () ->
  fusion_repo_selected = $(repo_name_select).length > 0 && !!$(repo_name_select).find('option:selected').val()
  has_import_url       = !!$(import_url_field).val()
  disable('.external-import, .external-import a.btn, ' + import_url_field, fusion_repo_selected)
  disable('.git-fusion-import, .git-fusion-import select', has_import_url)

$ ->
  update_ui();
  $('body').on 'input', import_url_field, (e) ->
    update_ui()

  $('body').on 'change',repo_name_select, (e) ->
    update_ui()
