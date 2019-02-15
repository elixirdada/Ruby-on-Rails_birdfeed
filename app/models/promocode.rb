class Promocode < ApplicationRecord
  enum promo_type: [:eggs, :insider, :vib]
  has_many :promocodes_users, inverse_of: :promocode
  has_many :users, through: :promocodes_users
  has_many :promocode_roles
  has_many :roles, through: :promocode_roles
  accepts_nested_attributes_for :roles, allow_destroy: true

  validates :value, :promo_type, presence: true
end
