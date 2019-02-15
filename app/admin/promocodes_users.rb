ActiveAdmin.register PromocodesUser do
  menu false
  filter :user
  filter :promocode, collection: proc { Promocode.all.map {|p| [p.slug, p.id]} }
  
  index do
    selectable_column
    column :user, sortable: 'users.first_name'
    column "User Role" do |pu|
      pu.user.roles.pluck(:name).join(', ')
    end
    column "Promocode", sortable: 'promocodes.slug' do |pu|
      link_to pu.promocode.slug, admin_promocode_path(pu.promocode)
    end
    column "Promocode type", sortable: 'promocodes.promo_type' do |pu|
      pu.promocode.promo_type
    end

  end

  controller do
    def scoped_collection
      super.includes :user
      super.includes :promocode
    end
  end
end
