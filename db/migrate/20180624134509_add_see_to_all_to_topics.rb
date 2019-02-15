class AddSeeToAllToTopics < ActiveRecord::Migration[5.1]
  def change
    add_column :topics, :see_to_all, :boolean
  end
end
