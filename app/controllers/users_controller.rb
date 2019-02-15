class UsersController < ApplicationController
  include UsersHelper
  include ReleasesHelper

  before_action :authenticate_user!, except: [
        :index, :parse_youtube, :admin, :artist, :announcements_feed,
        :interviews_feed, :videos_feed, :others_feed, :artists, :leaderboard,
        :load_more, :get_tracks, :artist_releases, :artist_tracks, :badges]

  before_action :set_notifications, only: [:leaderboard, :index, :show, :home,
        :artist, :artists, :admin, :friends, :idols, :choose_profile,
        :announcement_feed, :release_feed, :chirp_feed, :artists_feed,
        :friends_feed, :others_feed, :artist_releases , :artist_tracks,
        :badges, :get_more_credits, :success_signup]

  before_action :set_enricher, except: [:artists]
  # before_action :set_enricher, only: [:artists], unless: :is_user_available?

  before_action :set_userpage_feed, only: [:admin, :artist]


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => "Subscribe to get access to this action"
  end

  def set_enricher
    @enricher = StreamRails::Enrich.new
    @enricher.add_fields([:foreign_id])
    @activities = []
    @role_ids = Role.all.pluck(:id)
    @friends = current_user.follows.where(followable_type: 'User') if current_user
  end

  def set_userpage_feed
    @user = User.find(params[:id])

    begin
      feed = StreamRails.feed_manager.get_feed('user_aggregated', @user.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    @activities = @enricher.enrich_aggregated_activities(results)
    respond_to do |format|
      format.js { render 'feed.js.erb' }
      format.html
    end
  end

  def leaderboard
    @leader_users = leaderboard_query('leaders', 1, 5, true)
    @badge_kinds = BadgeKind.visible
  end

  def index
    @leader_users = leaderboard_query('leaders', params[:page] || 1, 9, true)
    @badge_kinds = BadgeKind.visible
  end

  def load_more
    @leader_users = leaderboard_query('leaders', params[:page], 9, false)
    @badge_kinds = BadgeKind.visible
  end

  def admin

    if @user.has_role? :artist
      redirect_to artist_path(@user) and return
    elsif !@user.has_role?(:admin) && !@user.has_role?(:artist)
      redirect_to user_path(@user) and return
    end

  end

  def show
    @user = User.where(id: params[:id])
    if @user.any?
      @user = @user.first
    else
      @user = User.where(profile_url: params[:id])
      if @user.any?
        @user = @user.first
      else
        @user = nil
      end
    end

    if @user.has_role? :artist
      redirect_to artist_path(@user) and return
    elsif @user.has_role? :admin
      redirect_to admin_path(@user) and return
    end

    if current_user.id != @user.id
      redirect_to player_favorites_path(@user) and return
    end

    @data_feed = current_user.id == @user.id ? "timeline_aggregated" : "user"

    fan_vars

    authorize! :read, @user unless @user == current_user

    begin
      if current_user.present? && @user.id == current_user.id

        feed = StreamRails.feed_manager.get_news_feeds(@user.id)[:aggregated]
      else
        feed = StreamRails.feed_manager.get_feed('user_aggregated', @user.id)

        # feed = StreamRails.feed_manager.get_user_feed(@user.id)
      end
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    @activities = @enricher.enrich_aggregated_activities(results)

    # current_user.change_points( 'member_over_time', nil ) if current_user == @user

    respond_to do |format|
      format.js { render 'feed.js.erb' }
      format.html
    end
  end

  def artist
    @user = User.where(id: params[:id])
    if @user.any?
      @user = @user.first
    else
      @user = User.where(profile_url: params[:id])
      if @user.any?
        @user = @user.first
      else
        @user = nil
      end
    end
    if !@user.has_role?(:admin) && !@user.has_role?(:artist)
      redirect_to user_path(@user) and return
    elsif @user.has_role? :admin
      redirect_to admin_path(@user) and return
    end

    authorize! :read, @user

    artist_vars
  end

  def artist_releases
    @user = User.find(params[:id])
    @playlists = @user.playlists.visible

    authorize! :read, @user

    page = params[:page] || 1
    @releases = releases_query(
      @user.releases.published.by_roles(current_user.try(:roles).try(:pluck, :id)),
      page,
      16,
      true
    )
  end

  def artist_tracks
    @user = User.find(params[:id])
    @playlists = @user.playlists.visible

    authorize! :read, @user

    page = params[:page] || 1
    # user_releases = "SELECT id FROM releases INNER JOIN releases_users ON releases_users.release_id = releases.id WHERE releases_users.user_id = #{@user.id}"
    # tracks_from_releases = "SELECT * FROM tracks WHERE release_id IN (#{user_releases})"
    @tracks = @user.releases_tracks
  end

  # def interviews_feed
  #   @user = User.find(params[:id])

  #   authorize! :read, @user

  #   artist_vars

  #   get_feed_from @user.announcements, "Announcement"

  #   render :home
  # end

  # def videos_feed
  #   @user = User.find(params[:id])

  #   authorize! :read, @user

  #   artist_vars

  #   get_feed_from @user.videos, "Addvideo"

  #   render :home
  # end

  # def others_feed
  #   @user = User.find(params[:id])

  #   authorize! :read, @user

  #   artist_vars

  #   begin
  #     feed = StreamRails.feed_manager.get_notification_feed(@user.id)
  #     results = feed.get()['results']
  #   rescue Faraday::Error::ConnectionFailed
  #     results = []
  #   end

  #   unseen = results.select { |r| r['is_seen'] == false }
  #   @unseen_count = unseen.count

  #   if @unseen_count <= 8
  #     @activities = @enricher.enrich_aggregated_activities(results[0..7])
  #   else
  #     @activities = @enricher.enrich_aggregated_activities(unseen)
  #   end

  #   if @user.has_role?(:artist)
  #     render :artist
  #   else
  #     render :show
  #   end
  # end

  def announcement_feed
    @user = current_user
    @data_feed = 'announcement_user_feed'
    fan_vars

    begin
      feed = StreamRails.feed_manager.get_feed('announcement_user_feed', current_user.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    @activities = @enricher.enrich_aggregated_activities(results)
    respond_to do |format|
      format.js { render 'feed.js.erb' }
      format.html { render :show }
    end
  end

  def release_feed
    @user = current_user
    @data_feed = 'release_user_feed'
    fan_vars

    begin
      feed = StreamRails.feed_manager.get_feed('release_user_feed', current_user.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    @activities = @enricher.enrich_aggregated_activities(results)

    respond_to do |format|
      format.js { render 'feed.js.erb' }
      format.html { render :show }
    end
  end

  def chirp_feed
    @user = current_user
    fan_vars

    begin
      feed = StreamRails.feed_manager.get_feed('chirp_user_feed', current_user.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    @activities = @enricher.enrich_activities(results)
    respond_to do |format|
      format.js { render 'feed.js.erb' }
      format.html { render :show }
    end
  end

  # def artists_feed
  #   @user = current_user
  #   fan_vars

  #   begin
  #     feed = StreamRails.feed_manager.get_news_feeds(@user.id)[:flat]
  #     results = feed.get()['results']
  #   rescue Faraday::Error::ConnectionFailed
  #     results = []
  #   end

  #   @activities = @enricher.enrich_activities(results).select { |a| a['actor'].has_role?(:artist) }

  #   render :show
  # end

  # def friends_feed
  #   @user = current_user
  #   fan_vars

  #   begin
  #     feed = StreamRails.feed_manager.get_news_feeds(@user.id)[:flat]
  #     results = feed.get()['results']
  #   rescue Faraday::Error::ConnectionFailed
  #     results = []
  #   end

  #   @activities = @enricher.enrich_activities(results).select { |a| !a['actor'].has_role?(:artist) }

  #   render :show
  # end

  def artist_vars
    @followers = @user.followers
    @releases = @user.releases.published
        .by_roles(current_user.try(:roles).try(:pluck, :id))
        .limit(30)

    @artist_video = @user.videos.last
    @followed_users = @user.followed_users.where("users.id NOT IN (?)", User.with_role(:artist).pluck(:id)).limit(4)
    @followed_artists = @user.followed_users.with_role(:artist).limit(4)
  end

  def fan_vars
    @followed_users = @user.followed_users.where("users.id NOT IN (?)", User.with_role(:artist).pluck(:id)).limit(4)
    @followed_artists = @user.followed_users.with_role(:artist).limit(4)

    @user_position = User
        .joins('LEFT OUTER JOIN badge_points on (users.id = badge_points.user_id)')
        .group('users.id')
        .order('users.created_at ASC, SUM(badge_points.value) DESC')
        .count.keys.index(@user.id) + 1
  end


  def badges
    @user = User.find(params[:id])
  end

  def home
    #force user to fill needed fields
    unless current_user.additional_info_set? || current_user.has_role?(:admin) || current_user.old_id
      redirect_to choose_profile_path(anchor: "step-1") and return
    end

    redirect_to correct_user_path(current_user)
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      @user.profile_completed! if @user.onboarding_step == 'set_profile'
    else
      logger.warn @user.errors.full_messages
    end

    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: '/') }
    end
  end

  def choose_profile
    if current_user.onboarding_step_before_type_cast > 2
      redirect_back(fallback_location: '/', flash: { alert: 'You have already completed your profile' })
    end
    countries = JSON.parse(File.read(Rails.root.join('app/assets/countries.json')))
    @countries = countries.sort.unshift(["US", "United States"]).map {|k,v| [v,k] }
  end

  def final_cancellation
  end

  def get_more_credits
    #TODO add notify if 1 day left
    redirect_to home_path and return unless current_user.can_use_credits?
    render 'users/success_credits_buy' if params[:success]
  end

  def success_signup
    if params[:check_confirmation]
      unless current_user.confirmed_at
        redirect_back(fallback_location: '/success_signup', flash: { alert: 'Your emails was not confirmed' })
      else
        flash[:notice] = "Successfully confirmed email"
        redirect_to onboarding_index_path
      end
    elsif params[:confirmation_token]
      if params[:confirmation_token] == current_user.confirmation_token
        current_user.update(confirmed_at: DateTime.now)
        current_user.email_confirmed!
        flash[:notice] = "Successfully confirmed email"
      else
        flash[:alert] = "Email could not be confirmed"
      end
    elsif params[:resend_confirmation]
      return flash[:notice] = 'Your email is already confirmed' if current_user.confirmed_at
      Devise::Mailer.confirmation_instructions(current_user, current_user.confirmation_token).deliver
      current_user.update(confirmation_sent_at: DateTime.now)
      flash[:notice] = "Confirmation email sent. Please check your inbox"
    else
      current_user.regenerate_confirmation_token unless current_user.confirmation_token
      unless current_user.confirmation_sent_at
        Devise::Mailer.confirmation_instructions(current_user, current_user.confirmation_token).deliver
        current_user.update(confirmation_sent_at: DateTime.now)
      end
    end
  end

  def apply_promocode
    @flash = {}
    code = Promocode.find_by_slug params[:promocode]
    unless code
      @flash[:alert] = "Promocode doesn't exist."
      return
    end
    if code.roles && (current_user.roles & code.roles).empty? && (code.roles.count < Role.count)
      @flash[:alert] = "You do not have enough permissions to use this promocode"
      return
    end
    # if code.promo_type == 'eggs' && !current_user.braintree_subscription_id
    #   @flash[:alert] = "As a free user you cannot use this promocode"
    #   return
    # end
    begin
    current_user.promocodes << code
    rescue ActiveRecord::RecordNotUnique
    @flash[:alert] = "You have already activated this promocode"
    return
    rescue ActiveRecord::RecordInvalid => e
    @flash[:alert] = e.message
    return
    end

    @fresh_eggs = code.value if code.promo_type == 'eggs'
    @flash[:notice] = "Promocode has been activated"

    @message = "Promocode has been activated."

    if code.promo_type == 'eggs'
      @message << "#{code.value} eggs has been added"
    elsif code.promo_type == 'insider'
      @message << "You have promo Insider access."
    elsif code.promo_type == 'vib'
      @message << "You have promo VIB access."
    end
  end

  def terms_and_conduct
    current_user.update_attributes(terms_and_conditions: true, code_of_conduct: true)
    current_user.confirm_email! if current_user.onboarding_step_before_type_cast <= 2
  end

  def get_feed_from objects, verb, target
    results = objects.map do |object|
      { "updated_at" => object.created_at,
        "activities" => [{
          'actor' => @user,
          'object' => object,
          'target' => object.try(target.to_sym),
          'verb' => object.class.to_s,
          'foreign_id' => "#{object.class.to_s}:#{object.id}",
          'time' => object.created_at
        }],
        "activity_count" => 1,
        "verb" => verb }
    end

    @activities = @enricher.enrich_aggregated_activities(results)
  end

  def artists
    @artists = leaderboard_query(User.with_role(:artist), params[:page] || 1, 30, true)
    @user = current_user ? current_user : nil
  end

  def load_more_artists
    @artists = leaderboard_query(User.with_role(:artist), params[:page], 30, false)
  end

  def friends
    @user = User.find(params[:id])
    @friends = @user.followed_users.where("users.id NOT IN (?)", User.with_role(:artist).pluck(:id))
  end

  def idols
    @user = User.find(params[:id])
    @idols = @user.followed_users.with_role(:artist)
  end

  # def get_tracks
  #   user = User.find(params[:id])
  #   @tracks = user.tracks.order(track_number: :asc).map do |track|
  #     TrackPresenter.new(track, current_user)
  #   end

  #   # if current_user && current_user.current_playlist.present?
  #   #   current_user.current_playlist.update_attributes(
  #   #     tracks: user.tracks.map{|t| t[:id]}.join(','),
  #   #     current_track: "0:0")
  #   # end
  # end

  def cancel_subscription
    current_user.cancel_braintree_subscription

    flash[:notice] = 'Subscription was canceled'
    redirect_to choose_profile_path
  end

  private

    # def is_user_available?
    #   current_user ? false : true
    # end

    def user_params
      params.require(:user).permit(:avatar, :avatar_cache,
          :crop_x, :crop_y, :crop_w, :crop_h)
    end
end
