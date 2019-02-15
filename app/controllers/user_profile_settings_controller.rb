class UserProfileSettingsController < ApplicationController
  include UsersHelper
  include ReleasesHelper
  
  before_action :authenticate_user!
  before_action :set_notifications, only: [:rewards, :egg_credits, :headers, :skins, :downloads, :billing_order_history, :friends, :artists, :releases, :chirp_feeds, :notifications, :integrations, :cancel_account, :cancel_account_perform]
  before_action :set_user
	def rewards
	end	

	def egg_credits 
	end

	def headers
    @headers = Header.all
	end

	def skins
	end

	def downloads
		@downloads = current_user.downloads
	end

	def billing_order_history
    @billing_order_histories = Braintree::Transaction.search do |search|
      search.customer_id.is current_user.braintree_customer_id
    end
	end

	def friends
	    _friends = current_user.followed_users.where("users.id NOT IN (?)", User.with_role(:artist).pluck(:id))
	    @friends = []
	    _friends.map do |friend|
	    	friend_json = JSON.parse(friend.to_json)
	    	sub_friends = friend.followed_users.where("users.id NOT IN (?)", User.with_role(:artist).pluck(:id))
	    	@friends.push({
	    		info: friend,
	    		number_of_friends: sub_friends.length
	    	})
	    end
	    @friends
	end

	def artists
	    @artists = current_user.followed_users.with_role(:artist)
	end

	def releases
		release_follows = current_user.follows.where(followable_type: "Release")		
		@releases = []
		release_follows.each do |follow|
			release = Release.find(follow.followable_id)
			@releases.push release
		end
		@releases
	end

	def chirp_feeds
		release_follows = current_user.follows.where(followable_type: "Topic")		
		@topics = []
		release_follows.each do |follow|
			topic = Topic.find(follow.followable_id)
			@topics.push topic
		end
		@topics
	end

  def notifications
    if !current_user.notification
      @notification_settings = Notification.create(user_id: current_user.id)
    else
      @notification_settings = current_user.notification
    end
  end

  def integrations
    
  end

  def update_notification_settings
    @notification = Notification.find(notification_params[:id])
    if @notification.update notification_params
      redirect_to root_path
    else
      redirect_to 'notifications'
    end
  end

  def update_user_header
    @header = Header.find(params[:header][:id])
    if current_user.update(header_id: params[:header][:id])
      redirect_to root_path
    else
      redirect_to root_path
    end
  end

  def cancel_account

  end

  def cancel_account_perform
    user = current_user
    if params[:submit_source] == "CANCEL MY MEMBERSHIP LEVEL"
      current_user.cancel_braintree_subscription

      flash[:notice] = 'Subscription was canceled'
      if create_cancellation
        Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
        redirect_to final_cancellation_path
      else
        redirect_to usr_cancel_account_path
      end
    else
      current_user.soft_delete
      if create_cancellation
        UserMailer.account_cancel_mail_to_user(user.email, user.name).deliver
        UserMailer.account_cancel_mail_to_admin(cancellation_params, user.email).deliver
        Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
        yield current_user if block_given?
        redirect_to final_cancellation_path
      else
        redirect_to usr_cancel_account_path
      end
    end
  end

private
	def set_user
		@user = current_user
	end

  def notification_params
    params.require(:notification).permit(:id, :sound_main, :desktop_main, :email_important, :email_newsletter, :email_gaming, :social_profile_new_friend_alert, :social_profile_new_friend_email, :social_profile_new_favorite_alert, :social_profile_new_favorite_email, :social_feeds_comment_alert, :social_feeds_comment_email, :social_feeds_reply_alert, :social_feeds_reply_email, :social_feeds_follow_alert, :social_feeds_follow_email, :social_friends_new_alert, :social_friends_new_email, :social_friends_comment_alert, :social_friends_comment_email, :social_friends_follow_alert, :social_friends_follow_email, :social_playlists_new_alert, :social_playlists_new_email)
  end

  def cancellation_params
    params.permit(:why_cancel_account, :your_thoughts)
  end

  def create_cancellation
      current_user.cancellations.create(cancellation_params)    
  end
end
