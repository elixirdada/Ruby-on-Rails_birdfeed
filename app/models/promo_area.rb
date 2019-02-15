# frozen_string_literal: true

class PromoArea < ApplicationRecord
  before_validation do |model|
    model.topic_category_ids&.reject!(&:blank?)
  end

  mount_uploader :image, HeaderUploader
end
