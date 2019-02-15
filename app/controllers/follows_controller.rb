class FollowsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to choose_profile_path( message: "follows" ), :alert => "Subscribe to get access to this action"
  end
  
  def create
    follow = Follow.new(follow_params)
    follow.user_id = current_user.id
    followable_id = follow.followable_id
    
    if follow.followable_type == 'User'
      if follow.followable.has_role?(:artist) || follow.followable.open_for_follow?
        follow.save
      else
        follow_request = FollowRequest.where("followable_type = 'User' AND followable_id = ? AND user_id = ?",
          followable_id, current_user.id).last

        if follow_request.blank?
          current_user.follow_requests.create(
              followable_type: 'User', 
              followable_id: followable_id)
        end
      end
    else
      follow.save
    end

    if follow.new_record?
      follow = { 'followable_type' => 'User', 'followable_id' => followable_id } 
    end

    render 'toggle_follow', locals: {
              object: follow, 
              text: JSON.parse( params[:text] ), 
              classes: params[:classes] } 
  end

  def destroy
    follow = Follow.find_by_id(params[:id])

    return unless follow

    if follow.user_id == current_user.id
      if follow.destroy
        news_aggregated_feed = StreamRails.feed_manager.get_news_feeds(follow.user_id)[:aggregated]
        news_aggregated_feed.unfollow( follow.followable_type.downcase, follow.followable_id )

        unless follow.followable_type == "User"
          feed_for_tab = StreamRails.feed_manager
              .get_feed("#{follow.followable_type.downcase}_user_feed", follow.user_id)
          feed_for_tab.unfollow( follow.followable_type.downcase, follow.followable_id )
        end
      else
        @cant_unfollow = true
      end
    end

    render 'toggle_follow', locals: {
              object: follow, 
              text: JSON.parse( params[:text] ), 
              classes: params[:classes] } 
  end

  def reject_request
    @user_id = params[:user_id]

    follow_request = FollowRequest.where("followable_type = 'User' AND followable_id = ? AND user_id = ?",
      current_user.id, @user_id).last

    follow_request.update_attributes(show_notify: false)
  end

  def accept_request
    @user_id = params[:user_id]
    follow_request = FollowRequest.where("followable_type = 'User' AND followable_id = ? AND user_id = ?",
      current_user.id, @user_id).last

    return if follow_request.blank?

    follow_request.destroy

    Follow.create(user_id: current_user.id, 
                  followable_id: @user_id,
                  followable_type: 'User',
                  show_notify: false)
    Follow.create(user_id: @user_id, 
                  followable_id: current_user.id,
                  followable_type: 'User',
                  show_notify: true)
  end

  def is_seen_requests
    Follow.where( show_notify: true, 
                  followable_type: 'User', 
                  followable_id: current_user.id)
      .update_all(show_notify: false)

    render json: {}, status: :ok
  end

  private
    def follow_params
      params.permit(:followable_id, :followable_type)
    end

end