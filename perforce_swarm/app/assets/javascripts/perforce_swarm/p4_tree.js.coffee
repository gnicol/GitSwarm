class @P4Tree
  constructor: (element, fusion_server) ->
    this.$el = $(element)

    tree_url = '/gitswarm/p4_tree.json'
    tree_url = gon.relative_url_root + tree_url if gon.relative_url_root?

    this.$('.git-fusion-tree').jstree({
      "core" : {
        "themes" : {
          "dots" : false
        },
        'data' : {
          "url" : tree_url,
          "data" : (node) ->
            { "path" : node.id, "fusion_server" : fusion_server }
        }
      },
      "checkbox" : {
        'cascade' : 'up+undetermined',
        'three_state': false,
        "keep_selected_style" : false,
        "whole_node" : false,
        "tie_selection" : false
      },
      "conditionalselect" : (node, event) ->
        # Enforce that only one path is selected
        is_checked = node.state.checked
        this.uncheck_all()
        !is_checked
      "plugins" : [ "checkbox", "conditionalselect" ]
    })

    this.$el.on 'click', '.tree-save', (e) =>
      @addSavedMapping(@getNewBranchName(), @getNewPaths()[0]) if @isCurrentMappingValid()

    this.$('.git-fusion-tree').on 'check_node.jstree uncheck_node.jstree uncheck_all.jstree check_all.jstree', => @updateMapping()

    this.$el.on 'change input', '.new-branch-name', => @updateMapping()

  # Local jQuery finder
  $: (selector) ->
    this.$el.find(selector)

  getNewBranchName: ->
    $.trim(this.$('.new-branch-name').val())

  getNewPaths: ->
    this.$('.git-fusion-tree').jstree(true).get_bottom_checked()

  isCurrentMappingValid: ->
    !!(@getNewPaths().length && @getNewBranchName())

  updateMapping: ->
    branchName = @getNewBranchName()
    newPaths   = @getNewPaths()

    if @isCurrentMappingValid()
      this.$('.tree-save').enable()
    else
      this.$('.tree-save').disable()

    this.$('.current-mapping-branch').text(@getNewBranchName() || '')
    this.$('.current-mapping-path').text(@getNewPaths()[0] || '...')

  addSavedMapping: (branchName, nodePath) ->
    newBranch = """
    <li>
      <input type="hidden" style="display:none;" name="git_fusion_branch_mapping[#{branchName}]" value="#{nodePath}" />
      <div>#{branchName}<div style="float:right;">edit | delete</div></div>
      <div>//#{nodePath}</div>
    </li>
    """
    this.$('.content-list').append(newBranch)

