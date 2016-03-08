class @P4Tree
  restrictedDepot: null
  existing_mappings: null
  updating_branch: null

  constructor: (element, fusion_server, existing_mappings) ->
    this.$el           = $(element)
    @existing_mappings = existing_mappings
    tree_url           = '/gitswarm/p4_tree.json'
    tree_url           = gon.relative_url_root + tree_url if gon.relative_url_root?
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
        'depot-stream'  : { icon: 'fa-p4-depot-icon fa-p4-badge fa-p4-stream-badge' },
        'depot-local'   : { icon: 'fa-p4-depot-icon' },
        'depot-tangent' : { icon: 'fa-p4-depot-icon' },
        'depot-spec'    : { icon: 'fa-p4-depot-icon fa-p4-badge fa-p4-spec-badge' },
        'depot-remote'  : { icon: 'fa-p4-remote-depot-icon' },
        'depot-archive' : { icon: 'fa-p4-depot-icon fa-p4-badge fa-p4-archive-badge' },
        'depot-unload'  : { icon: 'fa-p4-depot-icon fa-p4-badge fa-p4-unload-badge' },
        'folder'        : { icon: 'fa-p4-depot-folder' },
        'folder-stream' : { icon: 'fa-p4-depot-folder fa-p4-badge fa-p4-stream-badge' }
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
      this.$tree.uncheck_all()
      isStream = $(e.currentTarget).is('.depot-stream')
      @filterDepots(isStream)

    # Use selected tree mapping in project
    this.$el.on 'click', '.tree-save', (e) =>
      @addSavedMapping(@getNewBranchName(), @getTreeLowestChecked()[0]) if @isCurrentMappingValid()

    # Remove a branch from the project mapping
    this.$el.on 'click', '.remove-branch', (e) =>
      e.preventDefault()
      e.stopPropagation()
      if confirm('Are you sure?')
        $(e.currentTarget).closest('li').remove()
        @cancelMappingEdit()
        @runTreeFilters()

    # Edit a branch in the project mapping
    this.$el.on 'click', '.edit-branch', (e) =>
      e.preventDefault()
      e.stopPropagation()
      @editSavedMapping($(e.currentTarget).closest('li'))

    # Cancel the current branch update
    this.$el.on 'click', '.cancel-update', (e) =>
      e.preventDefault()
      e.stopPropagation()
      @cancelMappingEdit()

  # Local jQuery finder
  $: (selector) ->
    this.$el.find(selector)

  disableFields: ->
    this.$('input, .btn').not('.disabled').addClass('field-disabled').disable()

  enableFields: ->
    this.$('.field-disabled').enable()

  # Setup default tree state
  treeLoad: ->
    #  Load previous mapping back into page (in case of form error, etc)
    if @existing_mappings
      @addSavedMapping(branch, mapping) for branch, mapping of @existing_mappings
    else
      @filterDepots(this.$('.depot-type-filter').data('value') == 'depot-stream')

    @enableFields()

  editSavedMapping: (row) ->
    @cancelMappingEdit() if @updating_branch
    mapping = row.data('mapping')
    row.addClass('updating')

    @clearBranchTree()
    @runTreeFilters()
    @updating_branch = { mapping: mapping, row: row }
    this.$('.tree-save .action').text('Update Branch')
    @loadEditMapping(mapping.branchName, mapping.nodePath)

  cancelMappingEdit: (remove) ->
    return unless @updating_branch
    if remove then @updating_branch.row.remove() else @updating_branch.row.removeClass('updating')
    @updating_branch = null
    this.$('.tree-save .action').text('Add Branch')
    @clearBranchTree()
    @runTreeFilters()

  # Filter the depots shown in the tree either by streams or regular depots
  # if stream is a string, we are only going to show the passed stream depot,
  # if it's a boolean, we treat it as a flag for the filtering depots by whether
  # they are a stream or not
  filterDepots: (stream) ->
    # Update the filter button
    filterLabel = this.$('.filter-actions .depot-type-filter')
    filterLabel.data('value', if stream then 'depot-stream' else 'depot-regular')
    filterLabel.find('.type-text').text(if stream then 'Stream Depots' else 'Regular Depots')

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
    # Check the node
    @openDeepNode(nodePath, => this.$tree.check_node(nodePath))

  # Recurse through nodes to reach the passed node pass, waiting for them to be
  # loaded from the server
  openDeepNode: (nodePath, callback) ->
    # Open and load the path
    depotMatcher  = /^\/\/[^\/]*/
    # create an array of the nodes by splitting the path, but
    # we need special consideration for the depot path
    depot    = depotMatcher.exec(nodePath)[0]
    paths    = nodePath.replace(depotMatcher, '').split('/')
    paths[0] = depot

    # Rebuild the each path's id from its parent's id
    # eg. the MAIN node's id is actually //depot/Jam/MAIN
    for value,i in paths
      paths[i] = "#{paths[i-1]}/#{value}" if i

    index         = 0
    open_recurse  = =>
      if index == paths.length - 1
        callback() if callback
      else
        this.$tree.open_node(paths[index++], open_recurse)

    open_recurse()

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
    nodeId = if $.type(node) == 'string' then node else node.id
    this.$tree.get_node(nodeId.match('//[^/]+')[0])

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

    if @updating_branch
      this.$('.tree-status').html('<a href="#" class="cancel-update">cancel update?</a>').show()

      # If we are updating a branch, but the branch name has changed, switch up the wording
      if @updating_branch.mapping.branchName != @getNewBranchName()
        this.$('.tree-save .action').text("Change Branch #{@updating_branch.mapping.branchName} to")
      else
        this.$('.tree-save .action').text('Update Branch')
    else
      this.$('.tree-status').html('').hide()

    this.$('.current-mapping-branch').text(@getNewBranchName() || '')
    this.$('.current-mapping-path').val(@getTreeLowestChecked()[0] || '')
    # Ensure we can see the right-hand side of the mapping
    this.$('.current-mapping-path')[0].scrollLeft = this.$('.current-mapping-path')[0].scrollWidth

  # enforce tree restrictions based on the mappings you already have
  runTreeFilters: ->
    filterButton      = this.$('.filter-actions a, .filter-actions .depot-type-filter')
    mappingFormInputs = this.$('.branch-list li').not('.updating').find('input')

    if mappingFormInputs.length
      depot            = @getDepotForNode(mappingFormInputs[0].value)
      options          = {stream: depot.id} if depot.type == 'depot-stream'
      @restrictedDepot = { type: depot.type, options: options }
      filterButton.removeClass('field-disabled').disable()
      this.$('.saved-branches .nothing-here-block').hide()
      @enableTooltip(filterButton)
      @filterDepots(options?.stream)
    else
      filterButton.enable()
      @disableTooltip(filterButton)
      @restrictedDepot = null
      this.$('.saved-branches .nothing-here-block').show() unless this.$('.branch-list li.updating input').length
      @filterDepots(this.$('.depot-type-filter').data('value') == 'depot-stream')

  # set the current tree selected mapping as field in the form to submit during project creation
  addSavedMapping: (branchName, nodePath) ->
    newBranch = """
    <li>
      <input type="hidden" style="display:none;" name="git_fusion_branch_mappings[#{branchName}]" value="#{nodePath}" />
      <div class="saved-branch-name">#{branchName}<div style="float:right;">
        <a class="edit-branch" href="#">edit</a> | <a class="remove-branch" href="#">delete</a>
      </div></div>
      <code class="saved-branch-path">#{nodePath}</code>
    </li>
    """
    newBranch = $(newBranch)
    newBranch.data('mapping', {branchName: branchName, nodePath: nodePath})

    # Replace any existing mapping for the same branch name
    # Or add a new branch mapping
    existing = (@updating_branch && @updating_branch.row) || this.$('.branch-list').find("[name='git_fusion_branch_mappings[#{branchName}]']")
    if existing.length
      existing.closest('li').replaceWith(newBranch)
    else
      this.$('.branch-list').append(newBranch)

    @cancelMappingEdit(true)
    @clearBranchTree()
    @runTreeFilters()

  restrictStreamSelection: (node) ->
    node      = this.$tree.get_node(node) if $.type(node) == 'string'
    depot     = @getDepotForNode(node)
    nodeDepth = node.parents.length - 1 # Depth of the node we are checking, minus one for the root node

    if depot.type == 'depot-stream'
      # mark the node as a stream if it's at the right streamDepth
      # otherwise disable the node
      if depot.data.streamDepth == nodeDepth
        this.$tree.set_type(node, 'folder-stream')
      else
        this.$tree.disable_node(node)
        this.$tree.disable_checkbox(node)

  # Called each time a node's children are loaded from the backend
  _treeNodeLoaded: (data) ->
    if data.status
      @restrictStreamSelection(child) for child in data.node.children
