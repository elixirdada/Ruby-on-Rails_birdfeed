class AddShowNotifyToFollows < ActiveRecord::Migration[5.1]
  def change
    add_column :follows, :show_notify, :boolean, default: true
  end
end
