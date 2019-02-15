class TopicsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_notifications, only: [:show]

  breadcrumb 'Categories', :chirp_index_path, match: :exact

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => "Subscribe to get access to this action"
  end

  def show
    @topic = Topic.find(params[:id])
    @followers = Follow.where(followable_id: Topic.last)
    @shares = Share.where(shareable_type: 'Topic', shareable_id: @topic.id)
    @users = []
    @topic.posts.each do |post|
      if !@users.include? post.user
        @users.push post.user
      end
    end
    # if ( @topic.user && @topic.user.has_role?(:artist) ) || !@topic.see_to_all
    #   authorize! :read, @topic
    # end

    if params[:chirp_id].present?
      @category = TopicCategory.find(params[:chirp_id])
    else
      @category = @topic.category
    end
    @new_post = Post.new

    @new_post.feed_images.build

    breadcrumb @category.title, chirp_path(@category), match: :exact
    breadcrumb @topic.title, chirp_topic_path(@category, @topic), match: :exact
  end

  def create
    topic = Topic.new(topic_params)

    authorize! :create, topic

    topic.user_id = current_user.id
    if topic.save
      flash[:notice] = 'Topic was created'
    else
      flash[:alert] = topic.errors.full_messages.join(', ')
    end

    redirect_to chirp_topic_path(topic.category, topic)
  end

  def topic_params
    params.require(:topic).permit(:body, :title, :category_id)
  end
end
