# frozen_string_literal: true

ActiveAdmin.register PromoArea do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  config.filters = false

  permit_params :image, :show_on_releases, :show_on_user_profile, :url, topic_category_ids: []

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :topic_category_ids,
              as: :select, multiple: true,
              collection: TopicCategory.all.map { |tc| [tc.title.to_s, tc.id] },
              allow_blank: false

      f.input :show_on_releases, as: :boolean
      f.input :show_on_user_profile, as: :boolean
      f.input :url
      f.input :image, as: :file
    end

    f.actions
  end
end
