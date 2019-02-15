class Header < ApplicationRecord
  mount_uploader :url, HeaderUploader

  has_many :users

end
