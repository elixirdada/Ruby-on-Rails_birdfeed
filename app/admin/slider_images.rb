ActiveAdmin.register SliderImage do
  config.filters = false
  
  permit_params :image, :priority, :text, :imageurl, :image_url_target

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :image
      f.input :priority
      f.input :text
      f.input :imageurl
      f.input :image_url_target, as: :select, label: "Page Target", collection: ["Self","Blank Window"], include_blank: false
    end

    f.actions do
      f.action :submit, button_html: {name: 'save_and_stay'}, label: 'Update'
      f.action :submit, button_html: {name: 'save_and_list'}, label: 'Save & Close'
      f.cancel_link({
        action: "index"
      })
    end
  end

end
