class PromocodeRole < ApplicationRecord
  belongs_to :role
  belongs_to :promocode
end
