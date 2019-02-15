ActiveAdmin.register TopicCategoryGroup do

  permit_params :title, :prior, :image,
      categories_attributes: [:id, :title, :prior, :image, :group, :new_category_option, :_destroy]

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions

    f.inputs do
      image = f.object.image.present? ? image_tag(f.object.image.url, style: "background-color: gray;") : ''
      f.input :title
      f.input :image, hint: image
      f.input :image_cache, as: :hidden
      f.input :prior
    end

    f.inputs do
      f.has_many :categories, allow_destroy: true do |t|
        c_image = f.object.image.present? ? image_tag(f.object.image.url) : ''
        t.input :title
        t.input :image, hint: c_image, as: :jcropable
        t.input :image_cache, as: :hidden
        t.input :prior
        t.input :new_category_option
      end
    end

    f.actions
  end

end

ActiveAdmin.register TopicCategory do
  menu false
  jcropable
end