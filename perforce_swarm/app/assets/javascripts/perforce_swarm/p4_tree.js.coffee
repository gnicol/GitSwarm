class @P4Tree
  restrictedDepot: null

  constructor: (element, fusion_server) ->
    this.$el = $(element)
    tree_url = '/gitswarm/p4_tree.json'
    tree_url = gon.relative_url_root + tree_url if gon.relative_url_root?
    @disableFields()

    # Initialize the tree UI component
    this.$('.git-fusion-tree').on 'loaded.jstree', => @treeLoad()
    this.$('.git-fusion-tree').on 'load_node.jstree', (event, data) => @_treeNodeLoaded(data)
    this.$('.git-fusion-tree').jstree({
      'core' : {
        'themes' : { 'dots' : false },
        'data'   : {
          'url'  : tree_url,
          'data' : (node) ->
            # Return the $.ajax params to use in the request to the server for lazy loading
            { 'path' : node.id, 'fusion_server' : fusion_server }
        }
      },
      'checkbox' : {
        'cascade'             : 'up+undetermined', # we don't cascade checking down
        'three_state'         : false, # off for now, as it enforces other behaviour, @TODO bring this visual style back
        'keep_selected_style' : false, # Don't style nodes that are 'selected' (different than checked)
        'whole_node'          : false, # Don't check the node if you click it's label
        'tie_selection'       : false  # Do our own management of the selected nodes
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

    # Wire up selection change events
    this.$el.on 'change input', '.new-branch-name', => @updateMapping()
    this.$('.git-fusion-tree').on 'check_node.jstree uncheck_node.jstree uncheck_all.jstree check_all.jstree', =>
      @updateMapping()

    # Filter by depot-type
    this.$el.on 'click', '.filter-actions a', (e) =>
      e.preventDefault()
      this.$tree.show_all()
      this.$tree.uncheck_all()
      isStream = $(e.currentTarget).is('.depot-stream')
      filterLabel = this.$('.filter-actions .depot-type-filter')
      filterLabel.data('value', if isStream then 'depot-stream' else 'depot-regular')
      filterLabel.find('.type-text').text(if isStream then 'Stream Depots' else 'Regular Depots')
      @filterDepots(isStream)

    # Use selected tree mapping in project
    this.$el.on 'click', '.tree-save', (e) =>
      @addSavedMapping(@getNewBranchName(), @getTreeLowestChecked()[0]) if @isCurrentMappingValid()

    # Remove a branch from the project mapping
    this.$el.on 'click', '.remove-branch', (e) =>
      e.preventDefault()
      e.stopPropagation()
      $(e.currentTarget).closest('li').remove()
      @runTreeFilters()

    # Edit a branch in the project mapping
    this.$el.on 'click', '.edit-branch', (e) =>
      e.preventDefault()
      e.stopPropagation()
      row = $(e.currentTarget).closest('li')
      mapping = row.data('mapping')
      @loadEditMapping(mapping.branchName, mapping.nodePath)
      row.remove()
      @runTreeFilters()

  # Local jQuery finder
  $: (selector) ->
    this.$el.find(selector)

  disableFields: ->
    this.$('input, .btn').not('.disabled').addClass('field-disabled').disable()

  enableFields: ->
    this.$('.field-disabled').enable()

  # Setup default tree state
  treeLoad: ->
    @filterDepots(this.$('.depot-type-filter').data('value') == 'depot-stream')
    @enableFields()

  # Locks down the valid selections, and disables the
  # filter button in the tree based on depot type
  restrictDepotType: (type, options = {}) ->
    filterButton = this.$('.filter-actions a, .filter-actions .depot-type-filter')
    if type
      @restrictedDepot = { type: type, options: options }
      filterButton.removeClass('field-disabled').disable()
      @enableTooltip(filterButton)
    else
      @restrictedDepot = null
      filterButton.enable()
      @disableTooltip(filterButton)

  # Filter the depots shown in the tree either by streams or regular depots
  # if stream is a string, we are only going to show the passed stream depot,
  # if it's a boolean, we treat it as a flag for the filtering depots by whether
  # they are a stream or not
  filterDepots: (stream) ->
    depots = this.$tree.get_node('#').children
    for depot in depots
      node = this.$tree.get_node(depot)
      if !stream && node.type == 'depot-stream'
        # Hide stream depots when we aren't showing the stream depot type
        this.$tree.hide_node(node)
      else if stream && (node.type != 'depot-stream' || ($.type(stream) == 'string' && node.id.search(stream) != 0))
        # Hide any node that doesn't match the stream filter
        this.$tree.hide_node(node)
      else
        # Make sure we show any nodes we aren't filtering out
        this.$tree.show_node(node)

  # Expand and select a node
  loadEditMapping: (branchName, nodePath) ->
    this.$('.new-branch-name').val(branchName).trigger('change')
    @openAndSelectDeepNode(nodePath)

  # Recurse through nodes to reach the passed node pass, waiting for them to be
  # loaded from the server, and then check the passed nodePath once it's loaded
  openAndSelectDeepNode: (nodePath) ->
    # Open and load the path
    depotMatcher  = /^\/\/[^\/]*/
    # create an array of the nodes by splitting the path, but
    # we need special consideration for the depot path
    depot         = depotMatcher.exec(nodePath)[0]
    paths         = nodePath.replace(depotMatcher, '').split('/')
    paths[0]      = depot
    index         = 0
    (open_recurse = => this.$tree.open_node(paths[index++], open_recurse))()

    # Check the node
    this.$tree.check_node(nodePath)

  # Our own version of tree.get_bottom_checked that returns not the bottom
  # checked nodes, but instead, the lowest checked nodes.
  getTreeLowestChecked: (full) ->
    # recursive function for finding the lowest checked node of a passed node
    getNodeLowestChecked = (node) =>
      for child in node.children
        child = this.$tree.get_node(child)
        return getNodeLowestChecked(child) if child.state.checked

      return node

    checked       = this.$tree.get_top_checked(true)
    lowestChecked = []

    # Iterate over the checked depot nodes, then traverse down into them
    for node in checked
      lowestChecked.push(if full then getNodeLowestChecked(node) else getNodeLowestChecked(node).id)
    return lowestChecked

  clearBranchTree: ->
    this.$tree.uncheck_all()
    this.$('.new-branch-name').val('').trigger('change')

  getNewBranchName: ->
    $.trim(this.$('.new-branch-name').val())

  isCurrentMappingValid: ->
    # mapping must have a path and branch name
    return false unless @getTreeLowestChecked().length > 0 && !!@getNewBranchName()

    # If we are restricted to a particular depot type, we enforce that as well
    if @restrictedDepot
      for node in @getTreeLowestChecked()
        if @restrictedDepot.type == 'depot-stream'
          depot = @getDepotForNode(node)
          return false if depot.type != 'depot-stream' || node.search(depot.id) != 0
        else
          return false if @getDepotForNode(node).type == 'depot-stream'

    return true

  getDepotForNode: (node) ->
    node  = this.$tree.get_node(node) if $.type(node) == 'string'
    depot = if node.parents.length > 1 then node.parents[node.parents.length - 2] else node
    this.$tree.get_node(depot)

  enableTooltip: (element) ->
    this.$(element).closest('.tooltip-wrapper').addClass('has_tooltip').data('toggle', 'tooltip')

  disableTooltip: (element) ->
    this.$(element).closest('.tooltip-wrapper').removeClass('has_tooltip').removeAttr('data-toggle')

  # updates the area that displays your current tree selection
  updateMapping: ->
    if @isCurrentMappingValid()
      this.$('.tree-save').enable()
      @disableTooltip('.tree-save')
    else
      this.$('.tree-save').removeClass('field-disabled').disable()
      @enableTooltip('.tree-save')

    this.$('.current-mapping-branch').text(@getNewBranchName() || '')
    this.$('.current-mapping-path').text(@getTreeLowestChecked()[0] || '...')

  # enforce tree restrictions based on the mappings you already have
  runTreeFilters: ->
    mappingFormInputs = this.$('.content-list input')
    if mappingFormInputs.length
      depot   = @getDepotForNode(mappingFormInputs[0].value)
      options = {stream: depot.id} if depot.type == 'depot-stream'
      @restrictDepotType(depot.type, options)
      @filterDepots(options?.stream)
    else
      @restrictDepotType(null)
      @filterDepots(this.$('.depot-type-filter').data('value') == 'depot-stream')

  # set the current tree selected mapping as field in the form to submit during project creation
  addSavedMapping: (branchName, nodePath) ->
    newBranch = """
    <li>
      <input type="hidden" style="display:none;" name="git_fusion_branch_mappings[#{branchName}]" value="#{nodePath}" />
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

  restrictStreamSelection: (node) ->
    node      = this.$tree.get_node(node) if $.type(node) == 'string'
    depot     = @getDepotForNode(node)
    nodeDepth = node.parents.length - 1 # Depth of the node we are checking, minus one for the root node

    # Disable node if depot is a stream depot, and the node
    # isn't a stream (determined by the depots stream depth)
    if depot.type == 'depot-stream' && depot.data.streamDepth != nodeDepth
        this.$tree.disable_node(node)
        this.$tree.disable_checkbox(node)

  # Called each time a node's children are loaded from the backend
  _treeNodeLoaded: (data) ->
    if data.status
      @restrictStreamSelection(child) for child in data.node.children
