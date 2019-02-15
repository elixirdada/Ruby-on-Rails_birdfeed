class BadgeKind < ApplicationRecord
  has_many :badge_points, dependent: :destroy
  has_many :badges, dependent: :destroy
  has_many :badge_action_types, dependent: :destroy

  scope :visible, -> { where("name IN (?)", ['music','forum','community']) }
end
