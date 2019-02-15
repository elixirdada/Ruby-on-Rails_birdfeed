class Release < ApplicationRecord
  has_many :likes, as: :likeable
  has_many :comments, as: :commentable
  has_many :tracks, dependent: :destroy
  has_many :announcements
  has_many :track_files, through: :tracks
  has_many :release_files
  has_many :downloads, through: :tracks

  enum encode_status: [:pending, :complete, :failed] # can be nil # TODO: remove this
  enum release_type: { 'Birdfeed Exclusive' => 1, 'Dirtybird' => 2 }

  has_and_belongs_to_many :users
  belongs_to :admin, optional: true, foreign_key: "admin_id", class_name: "User"

  has_many :releases_roles
  has_many :roles, through: :releases_roles

  after_create :add_to_general_feed,
    if: Proc.new { |r| r.release_date <= DateTime.now && r.published_at.blank? }
  before_update :change_published_date, if: :will_save_change_to_release_date?
  after_destroy :remove_from_general_feed

  accepts_nested_attributes_for :tracks, :allow_destroy => true

  validates :title, :release_date, :catalog, presence: true

  mount_uploader :avatar, ReleaseUploader
  mount_uploader :showcase, DefaultUploader

  ratyrate_rateable "main"

  include AlgoliaSearch

  include StreamRails::Activity
  # as_activity

  algoliasearch sanitize: true do
    attribute :title, :catalog, :upc_code, :text
    # tags [self.published? ? 'published' : 'unpublished']
  end

  scope :published, -> {
    where("published_at IS NOT NULL ").order(release_date: :desc)
  }

  scope :by_roles, ->(user_roles_ids) {
    user_roles_ids ||= []
    left_outer_joins(:releases_roles)
    .where("releases_roles.id IS NULL OR releases_roles.id IN (?)", user_roles_ids)
  }

  scope :without_roles, -> {
    left_outer_joins(:releases_roles).where(releases_roles: { id: nil })
  }

  def previous
    Release.where("id > ?", id).order("release_date ASC").first || Release.first
  end

  def user_allowed?(user)
    return false unless user
    return true if user.has_role?(:admin)
    return false unless published?
    return true if user.has_role?(:boss)
    return true if user.has_role?(:homey)
    return true if user.has_role?(:intern)
    return true if user.has_role?(:handler)
    return true if user.has_promo_period?(:vib)
    return true if available_to_all?
    return false unless user.subscription_started_at
    return false if user.subscription_length == 'monthly_insider'
    return false if user.subscription_length == 'yearly_insider'
    return true if !published_at.nil? && published_at >= user.subscription_started_at - 3.months
    false
  end

  def published?
    !published_at.nil? && published_at <= DateTime.now
  end

  def release_day
    release_date.strftime('%Y-%m-%d')
  end

  def release_year
    release_date.strftime('%Y')
  end

  def step_name
    "#{self.class.name}_#{id}"
  end

  def file_name
    "#{title} - #{artist} - Dirtybird".gsub(/[^0-9A-Za-z.\-\  ]/, '')
  end

  def download_uris
    return {} if release_files.empty?

    uris = {}

    %w[mp3 aiff flac wav].each do |format|
      rf = release_files.find_by(format: ReleaseFile.formats[format])
      uris[format.upcase] = rf.download_uri if rf
    end

    uris
  end

  def artists limit=nil
    if artist_as_string && artist.present?
      artist
    elsif users.any?
      artists = users.map(&:name)
      artists_count = artists.count

      if limit == 0 && artists_count > 1
        'Various Artists'
      elsif limit && artists_count > limit
        artists = artists[0..limit-1]
        artists = artists.map(&:strip).join(', ')
        artists += " & #{artists_count-limit} #{'other'.pluralize(artists_count-limit)}"
      else
        artists = artists.join(' & ')
      end
    elsif artist.present?
      artist
    else
      'Various Artists'
    end
  end

  def exclusive?
    self.release_type == 'Birdfeed Exclusive'
  end

  def dirtybird?
    self.release_type == 'Dirtybird'
  end

  def self.batch_fill_feeds
    release_create_feed = StreamRails.feed_manager.get_feed( 'release_create', 1 )
    masterfeed = StreamRails.feed_manager.get_feed( 'masterfeed', 1 )

    find_in_batches(start: 0, batch_size: 100) do |group|
      activities = group.map do |release|
        {
          actor: "User:#{User.with_role(:admin).first.id}",
          verb: "Release",
          object: "Release:#{release.id}",
          foreign_id: "Release:#{release.id}",
          time: release.release_date.iso8601
        }
      end

      release_create_feed.add_activities(activities)
      masterfeed.add_activities(activities)
    end
  end

  def add_to_general_feed
    release_create_feed = StreamRails.feed_manager.get_feed( 'release_create', 1 )
    masterfeed = StreamRails.feed_manager.get_feed( 'masterfeed', 1 )

    activity = {
      actor: "User:#{User.with_role(:admin).first.id}",
      verb: "Release",
      object: "Release:#{self.id}",
      foreign_id: "Release:#{self.id}",
      time: DateTime.now.iso8601
    }

    self.users.each do |user|
      user_feed = StreamRails.feed_manager.get_user_feed( user.id )
      user_feed.add_activity(activity)
    end

    release_create_feed.add_activity(activity)
    masterfeed.add_activity(activity)

    self.update_columns(published_at: DateTime.now)
  end

  def remove_from_general_feed
    feed = StreamRails.feed_manager.get_feed( 'release_create', 1 )
    feed.remove_activity("Release:#{self.id}", foreign_id=true)
  end

  private

    def change_published_date
      both_in_future = release_date_change_to_be_saved[0] > DateTime.now &&
          release_date_change_to_be_saved[1] > DateTime.now
      both_in_past = release_date_change_to_be_saved[0] <= DateTime.now &&
          release_date_change_to_be_saved[1] <= DateTime.now
      from_past_to_future = release_date_change_to_be_saved[0] <= DateTime.now &&
          release_date_change_to_be_saved[1] > DateTime.now
      from_future_to_past = release_date_change_to_be_saved[0] > DateTime.now &&
          release_date_change_to_be_saved[1] <= DateTime.now

      return true if both_in_future || both_in_past

      self.add_to_general_feed if from_future_to_past
      self.remove_from_general_feed if from_past_to_future
    end
end
