class @ReenableHelixMirroring
  constructor: (@opts) ->
    this.$el     = $('.reenable-mirror-wrapper')
    this.$button = $('.reenable-mirror-button-wrapper a')
    # perform an initial update based on the status, and start polling if mirroring is in progress
    @updateStatus(@opts.status, @opts.error, @opts.status == 'in_progress')
    this.$button.on 'click', (e) =>
      if confirm('Are you sure you want to re-enable Helix mirroring?')
        @reenableHelixMirroring()
      return false

  # Local jQuery finder
  $: (selector) ->
    this.$el.find(selector)

  reenableHelixMirroring: ->
    # make an AJAX request to re-enable mirroring for this project
    $.ajax(@opts.reenable_url, {
      type: 'POST',
      beforeSend: =>
        @updateStatus('in_progress')
      success: =>
        # immediately start polling the status URL, which will schedule subsequent polls
        @updateStatus('in_progress', null, true)
      error: (data) =>
        try
          data = $.parseJSON(data.responseText)
        catch e
          data = {}

        data.status  = 'error'
        data.error ||= 'An unexpected error occurred while attempting to re-enable.'
        @updateStatus(data.status, data.error, true)
    })

  updateStatus: (@status, @error, @polling) ->
    @updateStatusContent(@status, @error, @polling)
    if @polling && @status == 'in_progress'
      callback = => @pollStatus()
      setTimeout(callback, 2000)
      return

  pollStatus: ->
    $.ajax(@opts.reenable_status_url, {
      type: 'GET',
      dataType: 'json',
      success: (data) =>
        @updateStatus(data.status, data.error, true)
      error: =>
        error = 'An unexpected error occurred while polling for status. Please reload the page.'
        @updateStatus('error', error, true)
    })

  updateStatusContent: (@status, @error, @polling) ->
    spinner = '<div class="loading">' +
      '<p><i class="fa fa-spinner fa-spin"></i> Re-enabling mirroring</p>' +
      '</div>'
    if @status == 'in_progress'
      this.$button.addClass('disabled').prop('disabled', true) unless this.$button.prop('disabled')
      this.$('.reenable-status').html(spinner) unless this.$('.reenable-status .fa-spinner').length
    else if @status == 'mirrored'
      if @opts.success_redirect
        window.location.href = @opts.success_redirect
        return
      else
        location.reload()
    else if @status == 'error'
      this.$button.removeClass('disabled').prop('disabled', false) if this.$button.prop('disabled')
      this.$('.reenable-status').html(@errorHtml(@error, @polling))
    else if @polling
      location.reload()

  errorHtml: (@error, @polling) ->
    html   = '<br />'
    @error = $('<pre/>').text(@error).html()
    if @polling
      html += 'The following error occurred while attempting to re-enable the project:'
      html += '<pre>' + @error + '</pre>'
    else
      html += '<div class="reenable-error js-toggle-container">'
      html += 'The last time re-enabling was attempted, '
      html += '<a href="#" class="js-toggle-button">an error occurred.</a>'
      html += '<br />'
      html += '<pre class="js-toggle-content hide">' + @error + '</pre>'
      html += '</div>'
    html
