jQuery(document).on 'turbolinks:load', ->

  if App.cable.subscriptions.findAll('{"channel":"LikesChannel","feed":"likes"}').length == 0
    App.cable.subscriptions.create {
        channel: 'LikesChannel',
        feed: 'likes'
      },
      received: (data) ->
        console.log(data)
        button = $('#like-' + data.likeable_type + '-' + data.likeable_id)
        
        if data.count > 0
          button.siblings('.likes-count').html('(' + data.count + ')')
        else
          button.siblings('.likes-count').html('')

        count_part = $('#likes-count-' + data.likeable_type + '-' + data.likeable_id)
          .children('.likes-count')

        if data.count > 0
          count_part.html(data.count)
        else
          count_part.html('')
