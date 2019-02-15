class LikesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to choose_profile_path( message: "likes" ), :alert => "Subscribe to get access to this action"
  end

  def create
    like = Like.new(like_params)
    like.user_id = current_user.id
    like.save
    @likeable = like.likeable

    render 'toggle_like', locals: { like: like, style: params[:style] }
  end

  def destroy
    like = Like.find(params[:id]).destroy
    @likeable = like.likeable
    render 'toggle_like', locals: { like: like, style: params[:style] }
  end

  private

    def like_params
      params.permit(:likeable_type, :likeable_id)
    end
end
