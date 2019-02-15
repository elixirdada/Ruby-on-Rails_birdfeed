class AddNoteworthyToTopics < ActiveRecord::Migration[5.1]
  def change
    add_column :topics, :noteworthy, :boolean, default: false
  end
end
