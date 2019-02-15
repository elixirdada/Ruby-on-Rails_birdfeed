class Download < ActiveRecord::Base
  belongs_to :track
  belongs_to :user
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable

  enum format: [:wav, :aiff, :flac, :mp3_160, :mp3_320]

  after_create :add_points

  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_feed( 'masterfeed', 1 )]
  end

  def activity_object
    if self.release
      self.track.release
    else
      self.track
    end
  end

  def activity_verb
    self.release? ? "Release" : "Track"
  end

  def activity_should_sync?
    if self.user
        .downloads
        .where("release = TRUE AND created_at > ?", 
            DateTime.now.in_time_zone - 1.minute)
        .count > 1
      false
    else
      true
    end
  end

  private

    def add_points
      self.user.change_points( 'download', self.release ? "Release" : "Track" )
    end
end
