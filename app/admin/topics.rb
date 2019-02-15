ActiveAdmin.register Topic do

  permit_params :title, :body, :category_id, :pinned, :locked, :noteworthy,
    :see_to_all, :user_id, :created_at

  index do
    column :id
    column :title
    column :body
    column :user
    column :pinned
    column :locked
    column "Created at" do |topic|
      if topic.created_at >= DateTime.now
      span "Sheduled for #{topic.created_at.strftime('%Y-%m-%d %I:%M')}", class: 'sheduled'
      else
        topic.created_at
      end
    end
    column :category
    column :noteworthy

    actions
  end

  form do |f|
    f.actions do
      f.action :submit, button_html: {name: 'save_and_stay'}, label: 'Update'
      f.action :submit, button_html: {name: 'save_and_list'}, label: 'Save & Close'
      f.cancel_link({
        action: "index",
        params: {
          order: session[:topic_order] || 'id_desc',
          page: session[:topic_page] || 1
        }
      })
    end

    f.inputs do
      f.input :title
      f.input :body
      f.input :user
      f.input :pinned
      f.input :locked
      f.input :created_at, as: :date_time_picker, hint: 'Set the future for schedule'
      f.input :category, as: :select,
                collection: TopicCategory.all.map {|c| ["#{c.title} - #{c.group.title}", c.id] }
      f.input :noteworthy
    end

    f.actions do
      f.action :submit, button_html: {name: 'save_and_stay'}, label: 'Update'
      f.action :submit, button_html: {name: 'save_and_list'}, label: 'Save & Close'
      f.cancel_link({
        action: "index",
        params: {
          order: session[:topic_order] || 'id_desc',
          page: session[:topic_page] || 1
        }
      })
    end
  end

  controller do

    def scoped_collection
      Topic.unscoped
    end

    def create
      super do |success,failure|
        success.html {
          if params[:save_and_stay].present?
            redirect_to edit_resource_path
          elsif params[:save_and_list].present?
            redirect_to collection_path(
              order: session[:topic_order] || 'id_desc',
              page: session[:topic_page] || 1
            )
          end
        }
      end
    end

    def update
      super do |success,failure|
        success.html {
          if params[:save_and_stay].present?
            redirect_to edit_resource_path
          elsif params[:save_and_list].present?
            redirect_to collection_path(
              order: session[:topic_order] || 'id_desc',
              page: session[:topic_page] || 1
            )
          end
        }
      end
    end

    def index
      session[:topic_order] = params[:order]
      session[:topic_page] = params[:page]
      super
    end
  end
end
