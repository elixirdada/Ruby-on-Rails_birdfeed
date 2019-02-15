class Rate < ActiveRecord::Base
  belongs_to :rater, :class_name => "User"
  belongs_to :rateable, :polymorphic => true
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable

  #attr_accessible :rate, :dimension

  after_create :add_points
  after_destroy :remove_points

  include StreamRails::Activity
  as_activity

  def activity_notify
    [StreamRails.feed_manager.get_feed( 'masterfeed', 1 )]
  end

  def activity_actor
    rater
  end

  def activity_object
    self.rateable
  end

  def activity_verb
    self.rateable.class.to_s
  end

  private

    def add_points
      self.rater.change_points( 'rate', self.rateable_type )
    end

    def remove_points
      self.rater.change_points( 'rate', self.rateable_type, :destroy )
    end

end