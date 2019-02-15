class ProcessingTrackJob < ApplicationJob
  after_perform do |job|
    job.arguments.first.update_columns(uri_string: nil)
  end

  def perform(track)
    return if track.uri_string.blank?

    track.remote_uri_url = track.uri_string
    track.save
  end
end
