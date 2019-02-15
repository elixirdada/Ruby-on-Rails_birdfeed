class PostRelayJob < ApplicationJob
  def perform(object)
    renderer = CommentsController.renderer_with_signed_in_user(User.find object.user_id)

    template = renderer.render partial: 'posts/post', 
        locals: { post: object }

    ActionCable.server.broadcast "topic:#{object.topic_id}",
        object: template
  end
end
