ActiveAdmin.register Report do

  permit_params :comment, :closed
  
  index do
    selectable_column
    id_column
    column :created_at
    column :closed
    column "Admin's comment", :comment
    column :text
    column "Object" do |report|
      link_to "#{report.reportable_type}:#{report.reportable_id}", 
          report.reportable, target: "_blank"
    end
    column :user
    column :ip_address
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    
    f.inputs do
      f.input :closed
      f.input :comment
    end

    f.actions
  end

end
