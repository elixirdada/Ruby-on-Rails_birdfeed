class TrackFile < ActiveRecord::Base
  belongs_to :track
  validates :track, presence: true

  has_one :release, through: :track

  enum format: [:wav, :aiff, :flac, :mp3,
                :ogg, :zip_aiff, :zip_wav, :zip_flac, :zip_mp3]
  enum encode_status: [:pending, :complete, :failed]

  def uri
    "https://#{s3_bucket}.s3.amazonaws.com/#{s3_key}"
  end

  def download_uri
    Rails.application.routes.url_helpers.track_download_path(track, format: format)
  end

  private

  def ffmpeg_metadata
    [
      "artist=#{track.artist}",
      "title=#{track.title}",
      "album=#{track.release.title}",
      "genre=#{track.genre}",
      "date=#{track.release.release_year}",
      "year=#{track.release.release_year}",
      "track=#{track.track_number}/#{track.release.tracks.count}",
      'comment=birdfeed.dirtybirdrecords.com'
    ]
  end

  def ffmpeg_options
    {
      write_id3v1: 1,
      write_id3v2: 1,
      id3v2_version: 3,
      metadata: ffmpeg_metadata
    }
  end

  def encode_audio_options
    {
      wav: {
        preset: 'wav'
      },
      aiff: {
        ffmpeg: ffmpeg_options.merge(f: 'aiff')
      },
      flac: {
        preset: 'flac',
        ffmpeg: ffmpeg_options
      },
      mp3_160: {
        preset: 'mp3',
        bitrate: 160_000,
        ffmpeg: ffmpeg_options,
        artwork: true
      },
      mp3_320: {
        preset: 'mp3',
        bitrate: 320_000,
        ffmpeg: ffmpeg_options,
        artwork: true
      },
      ogg: {
        preset: 'ogg',
        artwork: true,
        ffmpeg: ffmpeg_options
      }
    }
  end

  def step_name(art_step = false)
    art_step ? "#{self.class.name}_#{id}_before-artwork" : "#{self.class.name}_#{id}"
  end
end
