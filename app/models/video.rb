class Video < ApplicationRecord
  belongs_to :user
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable

  validates :user_id, :title, :video_link, presence: true

  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_feed( 'masterfeed', 1 )]
  end

  def activity_verb
    'Addvideo'
  end

  def activity_object
    self
  end

  def activity_foreign_id
    "Addvideo:#{self.id}"
  end

  def parse_youtube
    regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
    if self.video_link.present? && self.video_link.match(regex).present?
      self.video_link.match(regex)[1]
    end
  end

end
