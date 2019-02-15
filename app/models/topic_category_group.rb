class TopicCategoryGroup < ApplicationRecord
  mount_uploader :image, DefaultUploader
  
  has_many :categories, foreign_key: 'group_id',
                        class_name: 'TopicCategory',
                        dependent: :destroy
  accepts_nested_attributes_for :categories, allow_destroy: true
end
