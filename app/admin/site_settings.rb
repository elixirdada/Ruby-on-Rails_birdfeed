ActiveAdmin.register SiteSetting do

  permit_params :ident, :val, :res

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    
    f.inputs do
      f.input :ident
      f.input :val, hint: ('link' if f.object && f.object.ident == 'main-area-promo')
      #TODO add setting type in the future instead
      f.input :res if f.object && f.object.ident == 'main-area-promo'
    end

    f.actions
  end

end
