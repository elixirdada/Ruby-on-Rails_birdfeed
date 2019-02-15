class TracksChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'tracks'
  end
end
