class ReleasesRole < ApplicationRecord
  belongs_to :role
  belongs_to :release
end
