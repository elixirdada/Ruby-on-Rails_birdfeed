class Share < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :shareable, polymorphic: true
end
