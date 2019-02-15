class TracksUser < ApplicationRecord
  after_create :trigger_tracks_count

  belongs_to :user
  belongs_to :track

  ratyrate_rateable "track_star"

  private

    def trigger_tracks_count
      if self.user.has_role?(:artist)
        artist_info = ArtistInfo.find_or_create_by(artist_id: self.user.id)
        artist_info.update_attributes(tracks_count: self.user.tracks.count)
      end
    end
end
