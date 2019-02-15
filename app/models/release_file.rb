class ReleaseFile < ActiveRecord::Base
  belongs_to :release
  # validates :release, presence: true

  enum format: [:wav, :aiff, :flac, :mp3, :ogg]
  enum encode_status: [:pending, :complete, :failed]

  def uri
    "https://#{s3_bucket}.s3.amazonaws.com/#{s3_key}"
  end

  def download_uri
    Rails.application.routes.url_helpers.release_download_path(release, format: format)
  end

  private

  def step_name
    "#{self.class.name}_#{id}"
  end
end
