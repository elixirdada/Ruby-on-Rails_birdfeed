class BadgePoint < ApplicationRecord
  belongs_to :user
  belongs_to :badge_kind, optional: true
end
