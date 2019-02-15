class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  validates :user_id, :followable_id, :followable_type, presence: true

  attr_accessor :skip_points

  after_create :add_points, unless: :skip_points
  after_create :add_to_feeds#, :feed_release_topic_announcement
  after_save :trigger_followers_count
  before_destroy :self_unfollow
  after_destroy :trigger_followers_count, :remove_points, :remove_from_aggregated_feed#, :unfeed_release_topic_announcement

  include StreamRails::Activity
  as_activity

  def activity_notify
    notify = [StreamRails.feed_manager.get_feed( 'masterfeed', 1 )]

    if self.followable_type == 'User'
      notify << StreamRails.feed_manager.get_notification_feed(self.followable_id)
      # notify << StreamRails.feed_manager.get_news_feeds(self.followable_id)[:flat]
    end

    notify
  end

  def activity_object
    self.followable
  end

  def activity_verb
    self.followable.class.to_s
  end

  private

    def add_to_feeds
      news_aggregated_feed = StreamRails.feed_manager.get_news_feeds(user_id)[:aggregated]
      news_aggregated_feed.follow( followable_type.downcase, followable_id )
      if followable_type == 'Topic'
        chirp_feed = StreamRails.feed_manager.get_feed('chirp_user_feed', user_id)
        chirp_feed.follow( 'topic_posts_feed', followable_id )
      end
      unless followable_type == "User"
        feed_for_tab = StreamRails.feed_manager
            .get_feed("#{followable_type.downcase}_user_feed", user_id)
        feed_for_tab.follow( followable_type.downcase, followable_id )
      end
    end

    def add_points
      self.user.change_points( 'follow', self.followable_type )
    end

    def remove_points
      self.user.change_points( 'follow', self.followable_type, :destroy )
    end

    # def feed_release_topic_announcement

    # end

    # def unfeed_release_topic_announcement

    # end

    def remove_from_aggregated_feed
      feed = StreamRails.feed_manager.get_user_feed(self.user_id)
      feed.remove_activity("Follow:#{self.id}", foreign_id=true)
      if self.followable_type == 'Topic'
        chirp_feed = StreamRails.feed_manager
            .get_feed('chirp_user_feed', user_id)
        chirp_feed.unfollow( 'topic_posts_feed', self.followable_id, keep_history=true )
      end
    end

    def trigger_followers_count
      if self.followable.class == User && self.followable.has_role?(:artist)
        artist_info = ArtistInfo.find_or_create_by(artist_id: self.followable.id)
        artist_info.update_attributes(followers_count: self.followable.followers.count )
      end
    end

    def self_unfollow
      throw(:abort) if followable.try(:user).try(:id) == user_id
    end
end
