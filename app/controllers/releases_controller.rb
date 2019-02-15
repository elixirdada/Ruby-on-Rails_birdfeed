# frozen_string_literal: true

class ReleasesController < ApplicationController
  include ReleasesHelper
  before_action :set_notifications, only: %i[show index]
  load_and_authorize_resource

  def show
    release = Release.find(params[:id])
    @release = ReleasePresenter.new(release, current_user)
    @shares = Share.where(shareable_type: 'Release', shareable_id: @release.id)
    begin
      feed = StreamRails.feed_manager.get_feed('release', @release.id)
      results = feed.get['results']
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    @enricher = StreamRails::Enrich.new
    @enricher.add_fields([:foreign_id])
    @activities = @enricher.enrich_activities(results)

    if params[:player]
      if params[:user_id]
        @user = User.find params[:user_id]
        @playlists = @user.playlists.visible
      end

      render('player/release') && return
    end
  end

  def index
    @filters = params[:filters]
    page = params[:page] || 1
    per_page = params[:player] == 'true' ? 9 : 16

    @releases = Release.published.by_roles(current_user.try(:roles).try(:pluck, :id))

    @releases = set_filters @filters

    @releases = releases_query(@releases, page, per_page, true)

    @artists = User.with_role(:artist)

    if params[:player]
      if params[:user_id]
        @user = User.find params[:user_id]
        @playlists = @user.playlists.visible
      end

      render('player/releases') && return unless request.xhr?
    end

    if current_user && params[:player].blank?
      redirect_to releases_path(player: true, user_id: current_user.id)
    end
  end

  def set_filters(filters)
    if filters.present?
      filters.each do |filter, value|
        case filter
        when 'release_type'
          @releases = @releases.where('release_type = ?', value)
        when 'never_released'
          @releases = @releases.where('release_date > ? OR release_date = NULL', Date.today)
        when 'three_months'
          @releases = @releases.where('release_date >= ? AND release_date <= ?', Date.today - 3.months, Date.today)
        when 'year'
          @releases = @releases.where('extract(year from release_date) = ?', value)
        when 'artist'
          @releases = @releases.joins(:releases_users).where('releases_users.user_id = ?', value)
        when 'not_downloaded'
          @releases = @releases.where('release_date > ? OR release_date = NULL')
        when 'liked'
          tracks_likes = "SELECT release_id FROM tracks WHERE id IN (SELECT likeable_id FROM likes WHERE user_id = #{current_user.id} AND likeable_type = 'Track')"
          releases_likes = "SELECT likeable_id FROM likes WHERE user_id = #{current_user.id} AND likeable_type = 'Release'"

          @releases = @releases.where("id IN (#{tracks_likes} UNION #{releases_likes})")
        when 'type'
          @releases = @releases.where('release_type = ?', value)
        end
      end
    end

    @releases
  end

  def load_more
    @releases = Release.published.by_roles(current_user.try(:roles).try(:pluck, :id))
    @releases = set_filters params[:filters]
    @player_view = params[:player] == 'true'
    per_page = @player_view ? 9 : 16
    set_previous_page_on_player if @player_view

    @releases = releases_query(@releases, params[:page], per_page, false)
  end

  def download
    @release = Release.find(params[:id])

    unless @release.user_allowed?(current_user)
      raise ActionController::RoutingError, 'Not Found'
    end

    # special conditions for users from previous version of site
    if current_user.can_use_credits?
      if current_user.download_credits < 1
        redirect_to(root_path, alert: 'You have reached the limit of track downloads') && return
      end

      current_user.decrement!(:download_credits, @release.tracks.size)
    end

    @format = params[:format] || :mp3
    rf = ReleaseFile.find_by(release: @release, format: ReleaseFile.formats[@format])

    @release.tracks.each do |track|
      Download.create(user: current_user, track: track, format: Download.formats[@format], release: true)
    end

    redirect_to rf.url_string
    # redirect_to S3_BUCKET.object(rf.url_string).presigned_url(:get, response_content_disposition: 'attachment')
  end

  def get_tracks
    release = Release.find(params[:id])
    release_presenter = ReleasePresenter.new(release, current_user)
    @release_id = release_presenter.id

    @tracks = []

    release_presenter.tracks.each do |track|
      @tracks << {
        release_id: release_presenter.id,
        track_number: track.track_number,
        id: track.id,
        title: track.title,
        artists: track.artists,
        mp3: track.stream_uri
      }
    end

    # if current_user && current_user.playlists.present?
    #   current_user.current_playlist.update_attributes(
    #     tracks: release_presenter.tracks.map{|t| t[:id]}.join(','),
    #     current_track: "0:0")
    # end
  end

  def search
    @releases = params[:ids].map { |id| Release.find_by_id id }.compact
  end

  private

  def set_previous_page_on_player
    release_type = params[:filters].present? ? params[:filters][:release_type].to_i : 0

    if session[:page_on_player]
      session[:page_on_player][release_type] = params[:page]
    else
      session[:page_on_player] = []
    end
  end
end
