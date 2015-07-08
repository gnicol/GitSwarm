update_ui = () ->
  fusion_repo_selected = $('.git-fusion-import select#git_fusion_repo_name').find('option:selected').text() != ''
  import_url           = $('input#project_import_url').val() != ''
  external_elements    = '.external-import, .external-import > .centered-buttons > a.btn, .project-import .import-url-data'
  $(external_elements).toggleClass('disabled', fusion_repo_selected)
  $('input#project_import_url').attr('disabled', fusion_repo_selected ? 'disabled' : '')
  $('.git-fusion-import').toggleClass('disabled', import_url)
  $('.git-fusion-import select').attr('disabled', import_url ? 'disabled' : '')

$ ->
  $('body').on 'focus blur keyup', 'input#project_import_url', (e) ->
    update_ui()

  $('body').on 'change', '.git-fusion-import select#git_fusion_repo_name', (e) ->
    update_ui()
    e.preventDefault()
