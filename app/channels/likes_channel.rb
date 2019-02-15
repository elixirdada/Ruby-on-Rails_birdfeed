class LikesChannel < ApplicationCable::Channel
  def subscribed
    stream_from params[:feed]
  end
end
