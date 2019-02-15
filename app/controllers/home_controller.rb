class HomeController < ApplicationController
  include UsersHelper
  include StreamRails::Activity

  before_action :authenticate_user!,
      except: [:index, :about, :support, :birdfeed, :share, :report, :pricing,
          :information, :final_cancellation, :listen, :how_eggs_work, :connect, :play, :create_support, :support_message]
  before_action :set_notifications,
      only: [:about, :birdfeed, :pricing, :support, :support_message, :information, :how_eggs_work, :listen, :how_eggs_work]

  def index
    @slider = SliderImage.all.ordered

    @leader_users = leaderboard_query('leaders', 1, 10, true)

    @artists = User.with_role(:artist)
                   .order('created_at ASC')
                   .includes(:artist_info)
                   .limit(10)

    @releases = Release.published
        .by_roles(current_user.try(:roles).try(:pluck, :id))
        .where(
          'published_at <= :now AND (published_at >= :user_max OR available_to_all = true)',
          now: DateTime.now,
          user_max: DateTime.now - 2.month)
        .order('published_at DESC')
        .limit(10)

    @badge_kinds = BadgeKind.visible

    #TODO decrease count of queries
    # @leader_points = {}

    # @badge_points = BadgePoint.all.freeze

    # @leader_users.each do |user|
    #   @leader_points["leader_#{user.id}"] ||= {}
    #   @badge_kinds.each do |kind|
    #     @leader_points["leader_#{user.id}"]["kind#{kind.id}"] = @badge_points.where(user_id: user.id, badge_kind_id: kind.id).pluck(:value).sum
    #   end
    # end
  end

  def play
  end

  def listen
  end

  def about
  end

  def information
  end

  def final_cancellation
  end

  def birdfeed
    begin
      feed = StreamRails.feed_manager.get_feed('masterfeed', 1)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    @enricher = StreamRails::Enrich.new
    @enricher.add_fields([:foreign_id])
    @activities = @enricher.enrich_activities(results)
  end

  def share
    if params[:subtype].present? && params[:subtype_id].present?
      object = "#{params[:subtype].capitalize}:#{params[:subtype_id]}"
      _object_id = params[:subtype_id]
      verb = params[:subtype].capitalize
    else
      object = "#{params[:type].capitalize}:#{params[:type_id]}"
      _object_id = params[:type_id]
      verb = params[:type].capitalize
    end

    share = Share.create(
          user_id: current_user.try(:id),
          shareable_type: verb,
          shareable_id: _object_id,
          social: params[:social]
      )

    if current_user
      feed = StreamRails.feed_manager.get_user_feed( current_user.id )
      activity = {
        actor: "User:#{current_user.id}",
        verb: verb,
        object: object,
        foreign_id: "Share",
        social: params[:social],
        time: DateTime.now.iso8601
      }

      feed.add_activity(activity)

      current_user.change_points( 'share', params[:type].capitalize )
    end

    render json: {}
  end

  def badge_notify
    return unless current_user

    badges = []

    current_user.badge_levels.each do |level|
      unless level.notified?
        badges << level.badge_id
        level.update_attributes( notified: true )
      end
    end

    render json: { badges: badges }
  end

  def report
    report = Report.create(
          user_id: current_user.try(:id),
          reportable_type: params[:type],
          reportable_id: params[:id],
          ip_address: request.remote_ip,
          text: params[:text]
      )

    report_data = report.slice(:id,:user_id,:reportable_type,:reportable_id,:text)
    report_data[:text] = report_data[:text][0..30]
    SLACK_REPORTS.ping report_data.to_s

    admins = User.with_role(:admin)

    admins.each do |user|
      next if current_user && user.id == current_user.id

      feed = StreamRails.feed_manager.get_notification_feed( user.id )

      activity = {
        actor: "User:#{current_user.try(:id)}",
        verb: "Report",
        object: "#{params[:type]}:#{params[:id]}",
        foreign_id: "Report:#{report.id}",
        time: DateTime.now.iso8601
      }

      feed.add_activity(activity)
    end

  end

  def pricing
  end

  def create_support
    @support = Support.new(support_params)
    if @support.save
      UserMailer.support_center_email(params[:email], params[:topic], params[:message]).deliver
      flash[:notice] = "Query Succesfully Sent"
      redirect_to support_message_path
      # redirect_to root_path
    else
      flash[:alert] = "Unaable Send Query"
      root_path
    end
  end

  def support_message
  end

  def how_eggs_work
  end

  def connect
  end

  def about
  end
  private
  def support_params
    params.permit(:email, :topic, :message)
  end

end
