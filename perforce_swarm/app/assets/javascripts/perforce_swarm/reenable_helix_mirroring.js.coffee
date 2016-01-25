class @ReenableHelixMirroring
  constructor: (@opts) ->
    this.$el = $('.reenable-mirror-button-wrapper a')
    this.$el.on 'click', (e) =>
      @reenableHelixMirroring()
      return false

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
          this.$el.addClass('disabled').prop('disabled', true)
          $('.reenable-state').replaceWith(
            '<div class="reenable-state">' +
              '<div class="loading"><p><i class="fa fa-spinner fa-spin"></i> Re-enabling mirroring</p></div>' +
            '</div>')
    })

  updateReenableStatus: ->
    $.ajax(@opts.reenable_status_url, {
        type: 'GET',
        dataType: 'json',
        success: (data) =>
          $('.reenable-status').append(data)
          callback = -> reenable_helix_mirroring.updateReenableStatus()
          setTimeout(callback, 2000)
    })

