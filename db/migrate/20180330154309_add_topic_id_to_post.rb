class AddTopicIdToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :topic_id, :integer
  end
end
