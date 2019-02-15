class FeedsController < ApplicationController
  before_action :set_enricher
  before_action :authenticate_user!, except: [:get_feed_token]

  def is_seen
    begin
      feed = StreamRails.feed_manager.get_notification_feed(current_user.id)
      results = feed.get(mark_seen: true)
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    render json: {}, status: :ok
  end

  def is_read
    mark = params[:feed_group_id].present? ? [params[:feed_group_id]] : true
    begin
      feed = StreamRails.feed_manager.get_notification_feed(current_user.id)
      results = feed.get(mark_read: mark)
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

  end

  def get_feed_token
    if params[:feed].present?
      token = StreamRails.feed_manager.client.feed(params[:feed], params[:feed_id]).readonly_token
    end

    if params[:user_id].present?
      notify_token = StreamRails.feed_manager.client.feed('notification', params[:user_id]).readonly_token
    end

    render json: { 
                    token: token, 
                    key: ENV['STREAM_API_KEY'], 
                    app_id: ENV['STREAM_API_ID'],
                    notify_token: notify_token,
                  }
  end

  def add_feed_item
    params.permit!
    @new_item = params['new_item']['verb'].downcase
    @feed = params['feed']
    @feed_id = params['feed_id']

    sleep 3 #somehow new record not in the database yet

    if @feed == 'user' || 
          @feed == 'timeline' || 
          @feed == 'timeline_aggregated' ||
          @feed == 'release_user_feed' ||
          @feed == 'announcement_user_feed'
      @user = User.find_by_id params['feed_id']

      @activity = @enricher.enrich_aggregated_activities([
        { "updated_at" => params['new_item']['time'], 
          "activities" => [params['new_item']],
          "activity_count" => 1}
      ]).first

      @feed_item = render_to_string(partial: "aggregated_activity/userpage_#{ @new_item }", 
          locals: { activity: @activity } )
    else
      @activity = @enricher.enrich_activities([
        params['new_item']
      ]).first

      @feed_item = render_to_string(partial: "activity/commentable_#{ @new_item }", 
          locals: { activity: @activity } )
    end

  end

  def add_notify_item
    params.permit!
    @new_item = params['new_item']['verb'].downcase

    sleep 3 #somehow new record not in the database yet

    @activity = @enricher.enrich_aggregated_activities([
      { "updated_at" => params['new_item']['time'], 
        "activities" => [params['new_item']],
        "activity_count" => 1 }
    ]).first

  end

  def load_more
    @feed = params['feed']
    begin
      feed = StreamRails.feed_manager.get_feed(params['feed'], params['feed_id'])
      results = feed.get(limit: 10, id_lt: params['last_item_id'])['results']
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    if @feed == 'user_aggregated' || @feed == 'timeline_aggregated'
      @user = User.find_by_id params['feed_id']

      @activities = @enricher.enrich_aggregated_activities(results)
    else
      @activities = @enricher.enrich_activities(results)
    end
  end

  private

    def set_enricher
      @enricher = StreamRails::Enrich.new
      @enricher.add_fields([:foreign_id])
    end

end
