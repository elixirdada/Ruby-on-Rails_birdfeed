class LikeRelayJob < ApplicationJob
  def perform(object, action)
    renderer = LikesController.renderer_with_signed_in_user(User.find object.user_id)
    likeable = object.likeable

    if action == 'create'
      count = likeable.try(:likes_count) ? likeable.likes_count : likeable.likes.count
    else
      count = likeable.try(:likes_count) ? likeable.likes_count - 1 : likeable.likes.count - 1
    end

    ActionCable.server.broadcast 'likes',
      likeable_type: object.likeable_type,
      likeable_id: object.likeable_id,
      count: count
  end
end
