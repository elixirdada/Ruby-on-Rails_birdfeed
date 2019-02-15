class Playlist < ApplicationRecord
  belongs_to :user
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable

  scope :visible, -> { where(default: false) }

  def tracks_count
    tracks_ids.to_s.split(',').count
  end

  def tracks
    ids = tracks_ids.to_s.split(',').map do |track_id|
      track = Track.find_by_id track_id
      track.try(:release) ? track : nil
    end
    
    ids.compact
  end

  def name
    super.present? ? super : "My playlist #{id}"
  end
end
