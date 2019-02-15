class Announcement < ApplicationRecord
  belongs_to :admin, optional: true, foreign_key: "admin_id", class_name: "User"
  belongs_to :release, optional: true
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  enum avatar_size: { small: 0, large: 1 }

  after_create :add_to_general_feed,
    if: Proc.new { |a| a.release_date <= DateTime.now && a.published_at.blank? }
  before_update :change_published_date, if: :will_save_change_to_release_date?
  after_destroy :remove_from_general_feed

  mount_uploader :avatar, ReleaseUploader
  mount_uploader :showcase, DefaultUploader

  validates :title, :release_date, presence: true

  include StreamRails::Activity
  # as_activity

  def followers
    User.joins(:follows).where("follows.followable_id = ? AND follows.followable_type = 'Announcement'", self.id)
  end

  def self.batch_fill_feeds
    announcement_create_feed = StreamRails.feed_manager.get_feed( 'announcement_create', 1 )
    masterfeed = StreamRails.feed_manager.get_feed( 'masterfeed', 1 )

    find_in_batches(start: 0, batch_size: 100) do |group|
      activities = group.map do |announcement|
        {
          actor: "User:#{User.with_role(:admin).first.id}",
          verb: "Announcement",
          object: "Announcement:#{announcement.id}",
          foreign_id: "Announcement:#{announcement.id}",
          time: announcement.created_at.iso8601
        }
      end

      announcement_create_feed.add_activities(activities)
      masterfeed.add_activities(activities)
    end
  end

  def add_to_general_feed
    announcement_create_feed = StreamRails.feed_manager.get_feed( 'announcement_create', 1 )
    masterfeed = StreamRails.feed_manager.get_feed( 'masterfeed', 1 )

    activity = {
      actor: "User:#{User.with_role(:admin).first.id}",
      verb: "Release",
      object: "Announcement:#{self.id}",
      foreign_id: "Announcement:#{self.id}",
      time: DateTime.now.iso8601
    }

    announcement_create_feed.add_activity(activity)
    masterfeed.add_activity(activity)

    self.update_columns(published_at: DateTime.now)

    # User.with_role(:admin).all.each do |u|
    # User.joins(:roles).where('roles.name = ? "admin"')
    #   user_feed = StreamRails.feed_manager.get_user_feed(u.id)
    #   user_feed.add_activity(activity)
    # end
  end

  def remove_from_general_feed
    feed = StreamRails.feed_manager.get_feed( 'announcement_create', 1 )
    feed.remove_activity("Announcement:#{self.id}", foreign_id=true)
  end

  private

    def change_published_date
      both_in_future = release_date_change_to_be_saved[0] > DateTime.now &&
          release_date_change_to_be_saved[1] > DateTime.now
      both_in_past = release_date_change_to_be_saved[0] <= DateTime.now &&
          release_date_change_to_be_saved[1] <= DateTime.now
      from_past_to_future = release_date_change_to_be_saved[0] <= DateTime.now &&
          release_date_change_to_be_saved[1] > DateTime.now
      from_future_to_past = release_date_change_to_be_saved[0] > DateTime.now &&
          release_date_change_to_be_saved[1] <= DateTime.now

      return true if both_in_future || both_in_past

      self.add_to_general_feed if from_future_to_past
      self.remove_from_general_feed if from_past_to_future
    end
end
