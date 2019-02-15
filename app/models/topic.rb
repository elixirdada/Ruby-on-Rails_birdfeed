class Topic < ApplicationRecord
  default_scope { where("created_at <= ?", Time.now) }

  belongs_to :user
  belongs_to :category, foreign_key: 'category_id',
             class_name: "TopicCategory"
  has_many :likes, as: :likeable
  has_many :posts

  validates :title, :body, presence: true

  after_create :autofollow
  after_commit :add_to_feed, on: :create

  include AlgoliaSearch

  algoliasearch sanitize: true do
    attribute :title, :body
  end

  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_feed( 'masterfeed', 1 )]
  end

  def activity_object
    self
  end

  private


    def add_to_feed
      puts '--------Start Processing Topic Feed---------'
      new_topic_feed = StreamRails.feed_manager.get_feed("topic_create", 1)
      activity = {
                  actor: "User:#{self.user_id}",
                  verb: "NewTopic",
                  object: "Topic:#{self.id}",
                  foreign_id: "Topic:#{self.id}",
                  time: DateTime.now.iso8601
                }
      puts activity.inspect
      puts '----------End Processing------------'
      new_topic_feed.add_activity(activity)
    end

    def autofollow
      if self.user.followed( self ).blank?
        news_aggregated_feed = StreamRails.feed_manager.get_news_feeds(self.user_id)[:aggregated]
        notify_feed = StreamRails.feed_manager.get_notification_feed(self.user_id)

        self.user.follows.create(followable_id: self.id, followable_type: self.class.to_s)
        news_aggregated_feed.follow(self.class.to_s.downcase, self.id)
        notify_feed.follow(self.class.to_s.downcase, self.id)
      end
    end

end
