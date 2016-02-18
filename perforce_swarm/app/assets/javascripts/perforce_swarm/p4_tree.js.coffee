class @P4Tree
  restrictedDepot: null

  constructor: (element, fusion_server) ->
    this.$el = $(element)

    tree_url = '/gitswarm/p4_tree.json'
    tree_url = gon.relative_url_root + tree_url if gon.relative_url_root?

    this.$('.git-fusion-tree').on 'loaded.jstree', => @treeLoad()

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
      'types' : {
        'depot-stream' : {}
      },
      "conditionalselect" : (node, event) ->
        # Enforce that only one path is selected
        is_checked = node.state.checked
        this.uncheck_all()
        !is_checked
      "plugins" : [ "checkbox", "conditionalselect", "types" ]
    })
    this.$tree = this.$('.git-fusion-tree').jstree(true)

    this.$el.on 'click', '.filter-actions a', (e) =>
      e.preventDefault()
      this.$tree.show_all()
      this.$tree.uncheck_all()
      @filterDepots($(e.currentTarget).is('.depot-stream'))

    this.$el.on 'click', '.tree-save', (e) =>
      @addSavedMapping(@getNewBranchName(), @getTreeLowestChecked()[0]) if @isCurrentMappingValid()

    this.$('.git-fusion-tree').on 'check_node.jstree uncheck_node.jstree uncheck_all.jstree check_all.jstree', => @updateMapping()

    this.$el.on 'change input', '.new-branch-name', => @updateMapping()

    this.$el.on 'click', '.remove-branch', (e) =>
      e.preventDefault()
      e.stopPropagation()
      $(e.currentTarget).closest('li').remove()
      @runTreeFilters()

    this.$el.on 'click', '.edit-branch', (e) =>
      e.preventDefault()
      e.stopPropagation()
      row = $(e.currentTarget).closest('li')
      mapping = row.data('mapping')
      @populateTreeFromMap(mapping.branchName, mapping.nodePath)
      row.remove()
      @runTreeFilters()

  # Local jQuery finder
  $: (selector) ->
    this.$el.find(selector)

  treeLoad: ->
    filter = this.$('.depot-type-filter').data('value')

    @filterDepots(filter == 'depot-stream')

  restrictDepotType: (type, options = {}) ->
    if type
      @restrictedDepot = {type: type, options: options}
      this.$('.filter-actions a, .filter-actions .depot-type-filter').disable()
    else
      @restrictedDepot = null
      this.$('.filter-actions a, .filter-actions .depot-type-filter').enable()


  filterDepots: (stream) ->
    filterLabel = this.$('.filter-actions .depot-type-filter')
    filterLabel.data('value', if stream then 'depot-stream' else 'depot-regular')
    filterLabel.find('.type-text').text(if stream then 'Stream Depots' else 'Regular Depots')
    depots = this.$tree.get_node('#').children
    for depot in depots
      node = this.$tree.get_node(depot)
      if stream
        this.$tree.hide_node(node) if node.type != 'depot-stream'
      else
        this.$tree.hide_node(node) if node.type == 'depot-stream'

  populateTreeFromMap: (branchName, nodePath) ->
    this.$('.new-branch-name').val(branchName).trigger('change')

    # Open and load the path
    depotMatcher  = /^\/\/[^\/]*/
    depot         = depotMatcher.exec(nodePath)[0]
    paths         = nodePath.replace(depotMatcher, '').split('/')
    paths[0]      = depot
    index         = 0
    (open_recurse = => this.$tree.open_node(paths[index++], open_recurse))()

    # Check the node
    this.$tree.check_node(nodePath)

  getTreeLowestChecked: (full) ->
    getNodeLowestChecked = (node) =>
      for child in node.children
        child = this.$tree.get_node(child)
        return getNodeLowestChecked(child) if child.state.checked

      return node

    checked       = this.$tree.get_top_checked(true)
    lowestChecked = []
    for node in checked
      lowestChecked.push(if full then getNodeLowestChecked(node) else getNodeLowestChecked(node).id)
    return lowestChecked

  clearBranchTree: ->
    this.$tree.uncheck_all()
    this.$('.new-branch-name').val('').trigger('change')

  getNewBranchName: ->
    $.trim(this.$('.new-branch-name').val())

  isCurrentMappingValid: ->
    return false unless @getTreeLowestChecked().length > 0 && !!@getNewBranchName()

    if @restrictedDepot
      switch @restrictedDepot.type
        when 'depot-stream'
          for node in @getTreeLowestChecked(true)
            return false if @getDepotForNode(node).type != 'depot-stream'
        else
          for node in @getTreeLowestChecked(true)
            return false if @getDepotForNode(node).type == 'depot-stream'

    return true

  getDepotForNode: (node) ->
    node  = this.$tree.get_node(node) if $.type(node) == 'string'
    depot = if node.parents.length then node.parents[0] else node
    this.$tree.get_node(depot)

  updateMapping: ->
    if @isCurrentMappingValid()
      this.$('.tree-save').enable()
    else
      this.$('.tree-save').disable()

    this.$('.current-mapping-branch').text(@getNewBranchName() || '')
    this.$('.current-mapping-path').text(@getTreeLowestChecked()[0] || '...')

  runTreeFilters: ->
    mappingFormInputs = this.$('.content-list input')
    if mappingFormInputs.length
      @restrictDepotType(@getDepotForNode(mappingFormInputs[0].value).type)
    else
      @restrictDepotType(null)

  addSavedMapping: (branchName, nodePath) ->
    newBranch = """
    <li>
      <input type="hidden" style="display:none;" name="git_fusion_branch_mapping[#{branchName}]" value="#{nodePath}" />
      <div>#{branchName}<div style="float:right;">
        <a class="edit-branch" href="#">edit</a> | <a class="remove-branch" href="#">delete</a>
      </div></div>
      <div>#{nodePath}</div>
    </li>
    """
    newBranch = $(newBranch)
    newBranch.data('mapping', {branchName: branchName, nodePath: nodePath})
    this.$('.content-list').append(newBranch)
    @clearBranchTree()
    @runTreeFilters()


