ActiveAdmin.register Announcement do

  permit_params :avatar, :admin_id, :release_id, :release_date, :avatar_size, :title, :text,
  :feed_title, :bg_color, :url, :showcase

  jcropable

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions

    f.inputs do
      image = f.object.avatar.present? ? image_tag(f.object.avatar.url) : ''
      f.input :avatar, hint: image, as: :jcropable
      f.input :avatar_cache, as: :hidden
      f.input :avatar_size, as: :select, label: "Avatar Size",
          collection: Announcement.avatar_sizes.keys
      f.input :title
      f.input :feed_title
      f.input :bg_color
      f.input :url
      f.input :text, as: :quill_editor, input_html: {data: {options: {modules: {toolbar: [['bold', 'italic', 'underline'], ['link']]}, placeholder: 'Type something...', theme: 'snow'}}}
      f.input :release_date, as: :date_time_picker,
          hint: "Can't release deep in the past"
      f.input :admin, as: :select, label: "Admin",
          collection: User.with_role(:admin).map {|a| [a.name, a.id] }
      f.input :image_uri
      f.input :showcase, hint: image, as: :jcropable
      f.input :showcase_cache, as: :hidden
    end

    f.actions
  end
end
