class BadgeActionType < ApplicationRecord
  has_many :badge_dependencies
  has_many :badge_points_weights
  has_many :badges, through: :badge_points_weights
  belongs_to :badge_kind, optional: true

end
