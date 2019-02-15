class Badge < ApplicationRecord
  has_many :badge_levels, dependent: :destroy
  has_many :users, through: :badge_levels

  has_many :badge_dependencies, dependent: :destroy
  has_many :depended_badges, through: :badge_dependencies
  accepts_nested_attributes_for :badge_dependencies, :allow_destroy => true
  accepts_nested_attributes_for :depended_badges, :allow_destroy => true
  
  has_many :reverse_badge_dependencies, foreign_key: "depended_badge_id",
                                         class_name: "BadgeDependency",
                                         dependent: :destroy
  has_many :parent_badges,through: :reverse_badge_dependencies, source: :badge

  has_many :badge_points_weights
  accepts_nested_attributes_for :badge_points_weights, :allow_destroy => true
  has_many :badge_action_types, through: :badge_points_weights

  belongs_to :badge_kind
  validates :name, presence: true

  mount_uploader :image, DefaultUploader
end
