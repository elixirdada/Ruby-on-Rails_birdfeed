class TopicCategory < ApplicationRecord
  mount_uploader :image, HeaderUploader

  has_many :topics, foreign_key: 'category_id'
  belongs_to :group, foreign_key: 'group_id',
                     class_name: 'TopicCategoryGroup', optional: true

  validates :group_id, presence: true

  # include StreamRails::Activity
  # as_activity

  def promo_area
    PromoArea.where("'?' = ANY(topic_category_ids)", id).first
  end
end
