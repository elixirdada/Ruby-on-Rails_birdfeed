class CommentRelayJob < ApplicationJob
  def perform(object)
    renderer = CommentsController.renderer_with_signed_in_user(User.find object.user_id)

    if object.class.to_s == "Comment"
      template = renderer.render(partial: 'comments/comment',
          locals: { comment: object })
    elsif object.class.to_s == "Post"
      template = renderer.render(partial: 'posts/post',
          locals: { post: object })
    end
    puts 'calble'*100
    puts object.inspect
    ActionCable.server.broadcast 'comments',
      object: template,
      commentable_type: object.commentable_type.downcase,
      commentable_id: object.commentable_id,
      parent_id: object.parent_id
  end
end
