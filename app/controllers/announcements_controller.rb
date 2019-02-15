class AnnouncementsController < ApplicationController
  before_action :set_notifications
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to choose_profile_path( message: "announcements" ), :alert => "Subscribe to get access to this action"
  end

  def show
    @announcement = Announcement.find(params[:id])

    begin
      feed = StreamRails.feed_manager.get_feed('announcement', @announcement.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed, Stream::StreamApiResponseException
      results = []
    end

    @enricher = StreamRails::Enrich.new
    @enricher.add_fields([:foreign_id])
    @activities = @enricher.enrich_activities(results)
  end
end
