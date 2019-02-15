class CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to choose_profile_path( message: "comments" ), :alert => "Subscribe to get access to this action"
  end

  def show
    comment = Comment.find params[:id]

    if comment.commentable.try(:has_role?, :artist)
      action = 'artist'
    elsif comment.commentable.try(:has_role?, :admin)
      action = 'admin'
    else
      action = 'show'
    end

    redirect_to( url_for(
        controller: comment.commentable_type.pluralize.downcase,
        action: action,
        id: comment.commentable_id,
        anchor: "comment-#{comment.id}-inner" ) )
  end

  def create
    @comment_hash = comment_params[:comment_hash]
    if params[:comment][:feed_images_attributes].present? &&
            params[:comment][:feed_images_attributes]['0'][:image].blank?
      params[:comment].delete :feed_images_attributes
    end

    @comment = Comment.new(comment_params)

    if params[:comment][:body].blank? && params[:comment][:feed_images_attributes].blank?
      redirect_to @comment.commentable and return
    end

    if current_user.has_role?(:admin)
      @comment.user_id = params[:comment][:user_id] || current_user.id
    elsif current_user.can_handle?(params[:comment][:user_id])
      @comment.user_id = params[:comment][:user_id]
    elsif @comment.commentable_type == "User" &&
            @comment.commentable_id != current_user.id
      redirect_back(fallback_location: root_path) and return
    else
      @comment.user_id = current_user.id
    end
    @comment.vib_only = true if params['vib_only']
    if @comment.save
      if params[:roles] && @comment.commentable_type == "User" && !params['select_all_roles']
        params[:roles].keys.each do |key|
          @comment.roles << Role.find(params[:roles][key])
        end
      end
    else
      logger.warn(@comment.errors.full_messages)
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.edited_at = DateTime.now

    if current_user.id == @comment.user_id
      @comment.update_attributes(comment_params)
      flash[:notice] = 'Comment was updated'
    else
      flash[:alert] = "Comment wasn't updated"
    end

  end

  def destroy
    @comment = Comment.find(params[:id])

    if current_user.id == @comment.user_id
      @comment.destroy
      flash[:notice] = 'Comment was deleted'
    else
      flash[:alert] = "Comment wasn't deleted"
    end

  end

  def reply_form
    @parent_id = params[:parent_id]
    @commentable_id = params[:commentable_id]
    @commentable_type = params[:commentable_type]
    @comment_hash = SecureRandom.hex
    @new_comment = Comment.new
    @new_comment.feed_images.build
  end


  private

    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id,
        :body, :title, :parent_id, :likes_count, :shares_count, :comment_hash,
        :autofollow,
        feed_images_attributes: [:id, :feedable_id, :feedable_type, :image, :_destroy])
    end
end
