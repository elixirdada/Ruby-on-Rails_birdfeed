ActiveAdmin.register Comment do

  permit_params :body, :title, :likes_count, :replies_count, :shares_count, :parent_id
end
