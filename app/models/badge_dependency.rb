class BadgeDependency < ApplicationRecord
  belongs_to :badge
  belongs_to :depended_badge, class_name: "Badge"
  belongs_to :badge_action_type, optional: true
end
