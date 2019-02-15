ActiveAdmin.register BadgeActionType do

  permit_params :ident, :name, :badge_kind_id, :points, :count_to_achieve

  config.sort_order = 'badge_kind_id_asc'

  index do
    column :name
    column :badge_kind
    column :points
    column :count_to_achieve
    actions
  end
end
