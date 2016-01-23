class @ReenableHelixMirroring
  constructor: (@opts) ->
    console.log('REENABLE URL:' + @opts.reenable_url)
    console.log('STATUS URL:' + @opts.reenable_status_url)
    this.$el = $('.reenable-mirror-button-wrapper a')
    this.$el.on 'click', (e) =>
      console.log('Clicked')
      @reenableHelixMirroring()
      return false

  reenableHelixMirroring: ->
    console.log('Called reenableHelixMirroring')
    # make an AJAX request to re-enable mirroring for this project
    $.ajax(@opts.reenable_url, {
        type: 'POST',
        dataType: 'json',
        complete: (status) =>
          # immediately start polling the status URL, which will schedule subsequent polls
          console.log('STATUS: ' + status)
          @updateReenableStatus(2000)
          return false
        beforeSend: =>
          # disable the button and display an in progress message
          this.$el.addClass('disabled').prop('disabled', true)
          $('.reenable-state').replaceWith(
            '<div class="reenable-state">' +
              '<div class="loading"><p><i class="fa fa-spinner fa-spin"></i> Re-enabling mirroring</p></div>' +
            '</div>')
    })

  updateReenableStatus: (@delay) ->
    $.get @opts.reenable_status_url, (data) ->
      console.log('Called updateReenableStatus')
      $('.reenable-state').replaceWith(data)
      setTimeout(@updateReenableStatus(@delay), @delay)
      return false