class PlayerController < ApplicationController
  include ApplicationHelper
  include UsersHelper
  include PlayerHelper

  before_action :set_vars
  before_action :set_notifications,
      only: [:liked_tracks, :recently_tracks, :downloaded_tracks, :favorites,
        :liked_playlists, :connect, :listen, :artists, :playlists, :fans, :badges,
         :play, :my_badges, :all_badges, :headers_and_skins, :gaming_points]

  def liked_tracks
    @tracks = @user.liked_by_type('Track').map do |_track|
      TrackPresenter.new(_track, current_user, @browser)
    end

    @tracks.compact!
  end

  def recently_tracks
    @with_index = true
    @tracks = @user.recently_items.map do |item|
      TrackPresenter.new(item.track, current_user, @browser) if item.track
    end

    @tracks.compact!
  end

  def downloaded_tracks
    @tracks = @user.downloads.map do |d|
      TrackPresenter.new(d.track, current_user, @browser) if d.track
    end

    @tracks.compact!
  end

  def favorites
    @playlists = @user.liked_by_type('Playlist').limit(3)

    @tracks = @user.liked_by_type('Track').limit(7).map do |_track|
      TrackPresenter.new(_track, current_user, @browser)
    end

    @releases = @user.liked_by_type('Release').limit(3).map do |_release|
      ReleasePresenter.new(_release, current_user)
    end

    @tracks.compact!
    @releases.compact!
  end

  def liked_playlists
    @playlists = @user.liked_by_type('Playlist')
  end

  def connect
    if get_setting('main-area-promo')
      @main_area = { link: get_setting('main-area-promo'),
                     img: get_setting_res('main-area-promo')}
    else
      @main_area = nil
    end
  end

  def friends
    @user = current_user
    @friends = @user.followed_users.where("users.id NOT IN (?)", User.with_role(:artist).pluck(:id))
  end

  def play
    @membership = @user.badges
                       .joins(:badge_kind)
                       .where( badge_kinds: {ident:'membership_level'} )
    @general_badges = {}
    %w(music forum community).each do |ident|
      @general_badges[ident] = @user.badges
                         .joins(:badge_kind)
                         .where( badge_kinds: {ident: ident} )
    end
    @points = {
      listen: @user.points(BadgeKind.find_by_ident('music').try(:id)),
      connect: @user.points(BadgeKind.find_by_ident('forum').try(:id)),
      play: @user.points(BadgeKind.find_by_ident('community').try(:id))
    }

    @progress = {
      listen: @user.next_badges[BadgeKind.find_by_ident('music').try(:id)],
      connect: @user.next_badges[BadgeKind.find_by_ident('forum').try(:id)],
      play: @user.next_badges[BadgeKind.find_by_ident('community').try(:id)]
    }
  end

  def listen
    @top_releases = Release.published
        .by_roles(current_user.try(:roles).try(:pluck, :id))
        .order(created_at: :desc).limit(3)
    top_tracks_ids =
      RecentlyItem.group(:track_id)
                  .count
                  .sort_by {|k,v| v}
                  .reverse[0..4]
                  .map {|a| a[0]}
    @top_tracks = top_tracks_ids.map { |id| Track.find_by_id id }.compact
    @top_playlists = Playlist.visible.order(created_at: :desc).limit(3)
  end

  def artists
    @artists = leaderboard_query(User.with_role(:artist), params[:page] || 1, 30, true)
  end

  def load_more_artists
    @artists = leaderboard_query(User.with_role(:artist), params[:page], 30, false)
  end

  def fans
    @users = leaderboard_query('leaders', params[:page] || 1, 30, true)
  end

  def load_more_fans
    @users = leaderboard_query('leaders', params[:page], 30, false)
  end

  def playlists
    @playlists = Playlist.visible.order(created_at: :desc).limit(20)
  end

  def headers_and_skins
    @user = current_user
    @image, @image_title = header_image_details(@user)
  end

  def badges
    @membership = @user.badges
                       .joins(:badge_kind)
                       .where( badge_kinds: {ident:'membership_level'} )
    @general_badges = {}
    %w(music forum community).each do |ident|
      @general_badges[ident] = @user.badges
                         .joins(:badge_kind)
                         .where( badge_kinds: {ident: ident} )
    end
    @points = {
      listen: @user.points(BadgeKind.find_by_ident('music').try(:id)),
      connect: @user.points(BadgeKind.find_by_ident('forum').try(:id)),
      play: @user.points(BadgeKind.find_by_ident('community').try(:id))
    }

    @progress = {
      listen: @user.next_badges[BadgeKind.find_by_ident('music').try(:id)],
      connect: @user.next_badges[BadgeKind.find_by_ident('forum').try(:id)],
      play: @user.next_badges[BadgeKind.find_by_ident('community').try(:id)]
    }
  end

  private

    def set_vars
      @user = User.find params[:player_id]
      redirect_to root_path unless @user
    end

end
