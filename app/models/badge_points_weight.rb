class BadgePointsWeight < ApplicationRecord
  belongs_to :badge, inverse_of: :badge_points_weights
  belongs_to :badge_action_type, inverse_of: :badge_points_weights
end
