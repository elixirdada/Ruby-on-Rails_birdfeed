class TopicCategoriesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_notifications, only: [:show, :index]

  breadcrumb 'Categories', :chirp_index_path, match: :exact


  def index
    @groups = TopicCategoryGroup.all
    @noteworthy_topics = Topic.where({:noteworthy => true})
  end

  def show
    @category = TopicCategory.find(params[:id])
    @topic = Topic.new
    @pinned_topics = []
    @general_topics = []
    @category.topics.order(created_at: :desc).each do |topic|
      if topic.pinned 
        @pinned_topics.push(topic)
      else
        @general_topics.push(topic)
      end
    end
    breadcrumb @category.title, chirp_path(@category), match: :exact
  end
end
