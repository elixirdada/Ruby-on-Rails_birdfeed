jQuery(document).on 'turbolinks:load', ->

  if App.cable.subscriptions.findAll('{"channel":"CommentsChannel","feed":"comments"}').length == 0
    App.cable.subscriptions.create {
        channel: 'CommentsChannel',
        feed: "comments"
      },
      received: (data) ->
        console.log(data)
        if data.parent_id
          $('#comment-' + data.parent_id + '-inner')
            .next('.nested-messages')
            .append data.object
            .addClass 'replies'
        # if data.commentable_type == 'announcement'
        #   console.log 'announcer comment'
        #   $("#announcement-#{data.commentable_id}").append data.object
        else
          commentable = "#{data.commentable_type}-#{data.commentable_id}"
          $("##{commentable}-replies .feed-replies-list").append data.object

        $('#comment-reply-btn-' + data.commentable_id).show()
        $('.feed-replies-list .feed-form').remove()
        $('.feed-replies-list').siblings('.feed-form').remove()
        $('.no-feed-items').remove()
