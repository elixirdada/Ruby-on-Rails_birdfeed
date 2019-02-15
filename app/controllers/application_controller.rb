class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :store_user_location!, if: :storable_location?
  before_action :set_notification
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_online, :detect_player_pages
  before_action :check_for_terms_and_conduct, except: [:apply_promocode]

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  rescue_from ActiveRecord::RecordNotUnique, :with => :record_not_uniq

  helper_method :resource_name, :resource, :devise_mapping, :resource_class

  respond_to :html, :json

  include ApplicationHelper
  include ActionView::Helpers::UrlHelper

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def set_notifications
    if current_user
      begin
        feed = StreamRails.feed_manager.get_notification_feed(current_user.id)
        results = feed.get(limit: 20)['results']
      rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
        SLACK_GENERAL.ping "Stream::StreamApiResponseException #{request.env['HTTP_HOST']}"
        results = []
      end

      results = results.each { |r| r['activities'].delete_if { |a| a['actor'] == "User:#{current_user.id}" } }
      results = results.delete_if { |r| r['activities'].count == 0 }

      results.each do |r|
        r['activity_count'] = r['activities'].count
        r['actor_count'] = r['activities'].pluck('actor').uniq.count
      end

      unseen = results.select { |r| r['is_seen'] == false }
      @unseen_count = unseen.count
      @enricher = StreamRails::Enrich.new
      @enricher.add_fields([:foreign_id])

      if @unseen_count <= 8
        @notify_activities = @enricher.enrich_aggregated_activities(results[0..7])
      else
        @notify_activities = @enricher.enrich_aggregated_activities(unseen)
      end

      @credits = current_user.download_credits

      if current_user.has_role?(:artist)
        @friend_requests = current_user.followers.where("follows.show_notify = true")
      else
        @friend_requests = current_user.follow_requesters
                              .where("follow_requests.show_notify = true")
      end
    end
  end

  def self.renderer_with_signed_in_user(user)
    ActionController::Renderer::RACK_KEY_TRANSLATION['warden'] ||= 'warden'
    proxy = Warden::Proxy.new({}, Warden::Manager.new({})).tap { |i|
      i.set_user(user, scope: :user, store: false, run_callbacks: false)
    }
    renderer.new('warden' => proxy)
  end


  protected
    def detect_player_pages
      @browser = UserAgent.parse(request.env["HTTP_USER_AGENT"]).browser
      @ninja = User.find_by_id get_setting('ninja-id')

      @player_pages = false
      # @player_pages =
      #     (controller?('releases') && action?('index') && params[:player] == true ) ||
      #     controller?('player') ||
      #     (controller?('playlists') && action?('show'))
    end

    def set_notification
      request.env['exception_notifier.exception_data'] = {
        "server" => request.env['SERVER_NAME'],
        "current_user" => "#{current_user.try(:id)} #{current_user.try(:name)} #{current_user.try(:subscription_length)}"
      }
    end

    def set_online
      if current_user
        begin
          $redis_onlines.set( current_user.id, nil, ex: 60 )
        rescue Redis::CannotConnectError
          return false
        end
      end
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [
          :first_name, :last_name, :provider, :uid,
          :address_zip, :address_country, :address_state, :address_city,
          :address_line_1, :address_line_2,
          :birthdate, :gender, :t_shirt_size])
      devise_parameter_sanitizer.permit(:account_update, keys: [
          :first_name, :last_name, :provider, :uid,
          :address_zip, :address_country, :address_state, :address_city,
          :address_line_1, :address_line_2,
          :birthdate, :gender, :t_shirt_size])
    end

    def record_not_uniq
      #TODO(Victor) maybe bad desision, hard to control callbacks, use resque intead
      redirect_back(fallback_location: root_path) unless request.xhr?
    end

    def check_for_terms_and_conduct
      return unless current_user
      if !current_user.terms_and_conditions &&
          !current_user.code_of_conduct &&
          !controller?('callbacks/braintree') &&
          !current_page?(choose_profile_path) &&
          !current_page?(pricing_path) &&
          !current_page?(information_path) &&
          !current_page?(terms_and_conduct_path) &&
          !current_page?(success_signup_path) &&
          !devise_controller?
        redirect_to choose_profile_path
      elsif !current_user.old_user? && current_user.onboarding_step_before_type_cast > 2 && !current_user.onboarded?
        if !current_user.confirmed_at && action_name != 'success_signup'
          return redirect_to success_signup_path
        elsif current_user.onboarding_step_before_type_cast > 3
          return redirect_to(onboarding_index_path) if !controller?('onboarding') && action_name != 'update'
        end
      end
    end

    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
    end

    def store_user_location!
      store_location_for(:user, request.fullpath)
    end

end
