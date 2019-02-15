class SliderImage < ApplicationRecord
  mount_uploader :image, DefaultUploader
  scope :ordered, -> { order(priority: :asc, id: :desc) }
end
