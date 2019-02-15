class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to choose_profile_path( message: "posts" ), :alert => "Subscribe to get access to this action"
  end

  def show
    post = Post.find params[:id]

    redirect_to topic_path( post.topic, anchor: "message-#{post.id}" )
  end

  def new_form
    @topic = Topic.find(params[:topic_id])
    @topic_id = params[:topic_id]
    @post_hash = SecureRandom.hex
    @new_post = Post.new
    @new_post.feed_images.build
  end

  def create
    @post_hash = params[:post][:post_hash]
    if params[:post][:feed_images_attributes].present? &&
            params[:post][:feed_images_attributes]['0'][:image].blank?
      params[:post].delete :feed_images_attributes
    end

    @topic = Topic.find(params[:post][:topic_id])

    if params[:post][:body].blank? && params[:post][:feed_images_attributes].blank?
      redirect_to @topic and return
    end

    @post = Post.new(post_params)
    @post.user_id = current_user.id
    if @post.save
      # flash[:notice] = 'Post was created'
    else
      redirect_to @topic, alert: "Not an image"
      logger.warn @post.errors.full_messages
    end
  end

  def edit
    @comment = Post.find(params[:id])

    render "comments/edit"
  end

  def update
    @post = Post.find(params[:id])
    @post.edited_at = DateTime.now

    if current_user.id == @post.user_id
      @post.update_attributes(post_params)
      flash[:notice] = 'Comment was updated'
    else
      flash[:alert] = "Comment wasn't updated"
    end
  end

  def destroy
    @post = Post.find(params[:id])

    if current_user.id == @post.user_id
      @post.destroy
      flash[:notice] = 'Comment was deleted'
    else
      flash[:alert] = "Comment wasn't deleted"
    end
  end

  protected

    def post_params
      params.require(:post).permit(:body, :topic_id, :parent_id, :autofollow,
        feed_images_attributes: [
          :id, :feedable_id, :feedable_type, :image, :_destroy
        ])
    end
end
