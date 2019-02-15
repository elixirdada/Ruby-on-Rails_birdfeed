class Report < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :reportable, polymorphic: true

  scope :unsolved, -> { where(closed: false) }
end
