class CreateNotifications < ActiveRecord::Migration[5.1]
  def up
    create_table :notifications do |t|
      t.boolean :sound_main, default: true
      t.boolean :desktop_main, default: true
      t.boolean :email_important, default: true
      t.boolean :email_newsletter, default: true
      t.boolean :email_gaming, default: true
      t.boolean :social_profile_new_friend_alert, default: true
      t.boolean :social_profile_new_friend_email, default: true
      t.boolean :social_profile_new_favorite_alert, default: true
      t.boolean :social_profile_new_favorite_email, default: true
      t.boolean :social_feeds_comment_alert, default: true
      t.boolean :social_feeds_comment_email, default: true
      t.boolean :social_feeds_reply_alert, default: true
      t.boolean :social_feeds_reply_email, default: true
      t.boolean :social_feeds_follow_alert, default: true
      t.boolean :social_feeds_follow_email, default: true
      t.boolean :social_friends_new_alert, default: true
      t.boolean :social_friends_new_email, default: true
      t.boolean :social_friends_comment_alert, default: true
      t.boolean :social_friends_comment_email, default: true
      t.boolean :social_friends_follow_alert, default: true
      t.boolean :social_friends_follow_email, default: true
      t.boolean :social_playlists_new_alert, default: true
      t.boolean :social_playlists_new_email, default: true

      t.timestamps
    end
  end

  def down 
    drop_table :notifications
  end
end
