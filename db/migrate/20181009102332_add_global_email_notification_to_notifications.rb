class AddGlobalEmailNotificationToNotifications < ActiveRecord::Migration[5.1]
  def up
    add_column :notifications, :global_email_notification, :boolean, default: true
  end

  def down
    remove_column :notifications, :global_email_notification
  end
end
