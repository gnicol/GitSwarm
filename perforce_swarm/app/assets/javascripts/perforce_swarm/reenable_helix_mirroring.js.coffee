class @ReenableHelixMirroring
  constructor: (@opts) ->
    this.$el     = $('.reenable-mirror-wrapper')
    this.$button = $('.reenable-mirror-button-wrapper a')
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
        dataType: 'json',
        complete: =>
          # immediately start polling the status URL, which will schedule subsequent polls
          reenable_helix_mirroring.updateReenableStatus()
        beforeSend: =>
          # disable the button and display an in progress message
          this.$button.addClass('disabled').prop('disabled', true)
          @updateStatusContent(
            '<div class="reenable-status">' +
              '<div class="loading"><p><i class="fa fa-spinner fa-spin"></i> Re-enabling mirroring</p></div>' +
            '</div>')
    })

  updateStatusContent: (@html) ->
    this.$('.reenable-status').replaceWith(@html)

  updateReenableStatus: ->
    $.ajax(@opts.reenable_status_url, {
        type: 'GET',
        dataType: 'json',
        success: (data) =>
          # reload the page if the project is mirrored
          if data.status == 'mirrored'
            location.reload()
            return

          # update the status area with a spinner or error
          @updateStatusContent(data.html)

          # re-schedule status poll if we're in progress
          if data.status == 'in_progress'
            callback = -> reenable_helix_mirroring.updateReenableStatus()
            setTimeout(callback, 2000)
    })

