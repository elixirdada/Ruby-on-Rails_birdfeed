jQuery(document).on 'turbolinks:load', ->
  feed = $('.feed-block').data('feed')
  feedId = $('.feed-block').data('feedId')
  channel = '{"channel":"CommentsChannel","feed":"post"' + feedId + '}'

  if App.cable.subscriptions.findAll(channel).length == 0 && feed == 'topic'
    App.cable.subscriptions.create {
        channel: 'CommentsChannel',
        feed: "topic:" + feedId
      },
      received: (data) ->
        console.log(data)
        $('.feed-block').prepend data.object
        $("html, body").animate({ scrollTop: $("main") }, 500)

        $('#post_text').val('').focus();
        $('.emojionearea-editor').html('');
        file = $("[type='file']");
        file.val('');
        file.next('span').remove();
        file.next('button').remove();
