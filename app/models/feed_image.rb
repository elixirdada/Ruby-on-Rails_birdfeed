class FeedImage < ApplicationRecord
  mount_uploader :image, FeedImageUploader

  belongs_to :feedable, polymorphic: true, optional: true
end
