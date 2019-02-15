class ArtistInfo < ApplicationRecord
  belongs_to :user, foreign_key: "artist_id"
  mount_uploader :image, HeaderUploader

  def parse_youtube
    regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
    if self.video.present? && self.video.match(regex).present?
      self.video.match(regex)[1]
    end
  end

  include AlgoliaSearch

  algoliasearch sanitize: true do
    attribute :bio_short, :bio_long
  end
end
