# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190214195225) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "announcements", force: :cascade do |t|
    t.integer "admin_id"
    t.integer "release_id"
    t.string "title"
    t.text "text"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "old_id"
    t.string "image_uri"
    t.datetime "release_date"
    t.string "bg_color", default: "#8a8b8b"
    t.string "feed_title"
    t.string "url"
    t.integer "avatar_size"
    t.datetime "published_at"
    t.string "showcase"
  end

  create_table "artist_infos", force: :cascade do |t|
    t.string "bio_short"
    t.text "bio_long"
    t.string "facebook"
    t.string "twitter"
    t.string "instagram"
    t.integer "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "genre"
    t.integer "followers_count", default: 0
    t.integer "tracks_count", default: 0
    t.string "image"
    t.text "artist_q_a"
  end

  create_table "average_caches", force: :cascade do |t|
    t.bigint "rater_id"
    t.string "rateable_type"
    t.bigint "rateable_id"
    t.float "avg", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rateable_type", "rateable_id"], name: "index_average_caches_on_rateable_type_and_rateable_id"
    t.index ["rater_id"], name: "index_average_caches_on_rater_id"
  end

  create_table "badge_action_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "badge_kind_id"
    t.integer "points"
    t.integer "count_to_achieve", default: 1
    t.string "ident"
  end

  create_table "badge_dependencies", force: :cascade do |t|
    t.integer "badge_id"
    t.integer "depended_badge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "badge_kinds", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "prior", default: 0
    t.string "ident"
  end

  create_table "badge_levels", force: :cascade do |t|
    t.integer "badge_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "notified", default: false
    t.index ["badge_id", "user_id"], name: "index_badge_levels_on_badge_id_and_user_id", unique: true
  end

  create_table "badge_points", force: :cascade do |t|
    t.integer "user_id"
    t.integer "badge_kind_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "badge_id"
    t.integer "accumulated_count"
    t.integer "badge_action_type_id"
    t.datetime "accumulated_at"
  end

  create_table "badge_points_weights", force: :cascade do |t|
    t.integer "badge_id"
    t.integer "badge_action_type_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "condition"
    t.boolean "active", default: false
    t.index ["badge_id", "badge_action_type_id"], name: "index_badge_points_weights_on_badge_id_and_badge_action_type_id", unique: true
  end

  create_table "badges", force: :cascade do |t|
    t.string "name"
    t.integer "points"
    t.boolean "default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.integer "badge_kind_id"
    t.string "message"
  end

  create_table "billing_order_histories", force: :cascade do |t|
    t.string "order_id"
    t.date "transaction_date"
    t.string "product"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_billing_order_histories_on_user_id"
  end

  create_table "cancellations", force: :cascade do |t|
    t.string "why_cancel_account"
    t.string "your_thoughts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_cancellations_on_user_id"
  end

  create_table "comment_permissions", force: :cascade do |t|
    t.bigint "comment_id"
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_permissions_on_comment_id"
    t.index ["role_id"], name: "index_comment_permissions_on_role_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.text "body"
    t.integer "user_id"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "likes_count", default: 0
    t.integer "replies_count", default: 0
    t.integer "shares_count", default: 0
    t.datetime "edited_at"
    t.integer "old_id"
    t.boolean "vib_only", default: false
    t.string "author"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "downloads", force: :cascade do |t|
    t.bigint "track_id"
    t.bigint "user_id"
    t.integer "format"
    t.boolean "release", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "index_downloads_on_track_id"
    t.index ["user_id"], name: "index_downloads_on_user_id"
  end

  create_table "emails", force: :cascade do |t|
    t.string "subject", null: false
    t.text "body_html"
    t.text "body_text"
    t.string "from", null: false
    t.string "image_uri"
    t.string "title"
    t.string "cta_link"
    t.string "cta_text"
    t.string "template", null: false
    t.string "category"
    t.string "batch_id"
    t.datetime "send_at", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emails_users", force: :cascade do |t|
    t.bigint "email_id"
    t.bigint "user_id"
    t.index ["email_id"], name: "index_emails_users_on_email_id"
    t.index ["user_id"], name: "index_emails_users_on_user_id"
  end

  create_table "feed_images", force: :cascade do |t|
    t.integer "feedable_id"
    t.string "feedable_type"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follow_requests", force: :cascade do |t|
    t.integer "user_id"
    t.string "followable_type"
    t.integer "followable_id"
    t.boolean "show_notify", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "follows", force: :cascade do |t|
    t.integer "user_id"
    t.integer "followable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "followable_type"
    t.boolean "show_notify", default: true
    t.index ["followable_id"], name: "index_follows_on_followable_id"
    t.index ["user_id", "followable_id", "followable_type"], name: "index_follows_on_user_id_and_followable_id_and_followable_type", unique: true
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "headers", force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "likeable_id"
    t.string "likeable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "likeable_id", "likeable_type"], name: "index_likes_on_user_id_and_likeable_id_and_likeable_type", unique: true
  end

  create_table "meta_tags", force: :cascade do |t|
    t.string "meta_tags"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "index_meta_tags_on_resource_type_and_resource_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.boolean "sound_main", default: true
    t.boolean "desktop_main", default: true
    t.boolean "email_important", default: true
    t.boolean "email_newsletter", default: true
    t.boolean "email_gaming", default: true
    t.boolean "social_profile_new_friend_alert", default: true
    t.boolean "social_profile_new_friend_email", default: true
    t.boolean "social_profile_new_favorite_alert", default: true
    t.boolean "social_profile_new_favorite_email", default: true
    t.boolean "social_feeds_comment_alert", default: true
    t.boolean "social_feeds_comment_email", default: true
    t.boolean "social_feeds_reply_alert", default: true
    t.boolean "social_feeds_reply_email", default: true
    t.boolean "social_feeds_follow_alert", default: true
    t.boolean "social_feeds_follow_email", default: true
    t.boolean "social_friends_new_alert", default: true
    t.boolean "social_friends_new_email", default: true
    t.boolean "social_friends_comment_alert", default: true
    t.boolean "social_friends_comment_email", default: true
    t.boolean "social_friends_follow_alert", default: true
    t.boolean "social_friends_follow_email", default: true
    t.boolean "social_playlists_new_alert", default: true
    t.boolean "social_playlists_new_email", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "global_email_notification", default: true
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "overall_averages", force: :cascade do |t|
    t.string "rateable_type"
    t.bigint "rateable_id"
    t.float "overall_avg", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rateable_type", "rateable_id"], name: "index_overall_averages_on_rateable_type_and_rateable_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.integer "user_id"
    t.string "tracks_ids"
    t.string "current_track"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "default", default: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "image_url"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "topic_id"
    t.integer "user_id"
    t.integer "parent_id"
    t.integer "replies_count", default: 0
    t.datetime "edited_at"
    t.integer "likes_count"
    t.integer "old_id"
    t.string "author"
  end

  create_table "promo_areas", force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.string "topic_category_ids", default: [], array: true
    t.boolean "show_on_releases", default: false
    t.boolean "show_on_user_profile", default: false
  end

  create_table "promocode_roles", force: :cascade do |t|
    t.integer "promocode_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promocodes", force: :cascade do |t|
    t.string "slug"
    t.integer "promo_type"
    t.string "value"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_promocodes_on_slug", unique: true
  end

  create_table "promocodes_users", force: :cascade do |t|
    t.integer "promocode_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "promocode_id"], name: "index_promocodes_users_on_user_id_and_promocode_id", unique: true
  end

  create_table "rates", force: :cascade do |t|
    t.bigint "rater_id"
    t.string "rateable_type"
    t.bigint "rateable_id"
    t.float "stars", null: false
    t.string "dimension"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rateable_type", "rateable_id"], name: "index_rates_on_rateable_type_and_rateable_id"
    t.index ["rater_id"], name: "index_rates_on_rater_id"
  end

  create_table "rating_caches", force: :cascade do |t|
    t.string "cacheable_type"
    t.bigint "cacheable_id"
    t.float "avg", null: false
    t.integer "qty", null: false
    t.string "dimension"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cacheable_id", "cacheable_type"], name: "index_rating_caches_on_cacheable_id_and_cacheable_type"
    t.index ["cacheable_type", "cacheable_id"], name: "index_rating_caches_on_cacheable_type_and_cacheable_id"
  end

  create_table "recently_items", force: :cascade do |t|
    t.integer "user_id"
    t.integer "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "release_files", force: :cascade do |t|
    t.bigint "release_id"
    t.integer "format"
    t.string "s3_bucket"
    t.string "s3_key"
    t.integer "encode_status", default: 0, null: false
    t.string "encode_job_id"
    t.datetime "deleted_at"
    t.datetime "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url_string"
    t.index ["datetime"], name: "index_release_files_on_datetime"
    t.index ["deleted_at"], name: "index_release_files_on_deleted_at"
    t.index ["release_id"], name: "index_release_files_on_release_id"
  end

  create_table "releases", force: :cascade do |t|
    t.string "title"
    t.string "catalog"
    t.text "text"
    t.string "avatar"
    t.string "facebook_img"
    t.datetime "published_at"
    t.string "upc_code"
    t.boolean "compilation"
    t.datetime "release_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "available_to_all"
    t.integer "old_id"
    t.boolean "drip_source"
    t.string "image_uri"
    t.string "artist"
    t.integer "encode_status"
    t.boolean "artist_as_string"
    t.integer "admin_id"
    t.integer "release_type", default: 0
    t.string "buy_uri"
    t.string "assembly_id"
    t.boolean "assembly_complete"
    t.string "showcase"
  end

  create_table "releases_roles", force: :cascade do |t|
    t.integer "release_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "releases_users", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "release_id"
    t.index ["release_id", "user_id"], name: "index_releases_users_on_release_id_and_user_id", unique: true
    t.index ["release_id"], name: "index_releases_users_on_release_id"
    t.index ["user_id"], name: "index_releases_users_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "reportable_type"
    t.integer "reportable_id"
    t.string "text"
    t.integer "user_id"
    t.string "ip_address"
    t.string "comment"
    t.boolean "closed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "shares", force: :cascade do |t|
    t.integer "user_id"
    t.string "social"
    t.integer "shareable_id"
    t.string "shareable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "site_settings", force: :cascade do |t|
    t.string "ident"
    t.string "val"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "res"
  end

  create_table "slider_images", force: :cascade do |t|
    t.string "image"
    t.integer "priority"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imageurl", default: ""
    t.string "image_url_target", default: ""
  end

  create_table "supports", force: :cascade do |t|
    t.string "email"
    t.string "topic"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topic_categories", force: :cascade do |t|
    t.string "title"
    t.integer "prior", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
    t.string "image"
    t.boolean "new_category_option", default: false
  end

  create_table "topic_category_groups", force: :cascade do |t|
    t.string "title"
    t.integer "prior", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
  end

  create_table "topic_tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topic_tags_topics", force: :cascade do |t|
    t.bigint "topic_id"
    t.bigint "topic_tag_id"
    t.index ["topic_id"], name: "index_topic_tags_topics_on_topic_id"
    t.index ["topic_tag_id"], name: "index_topic_tags_topics_on_topic_tag_id"
  end

  create_table "topics", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "user_id"
    t.boolean "pinned"
    t.boolean "locked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_id"
    t.integer "old_id"
    t.boolean "see_to_all"
    t.boolean "noteworthy", default: false
  end

  create_table "track_files", force: :cascade do |t|
    t.bigint "track_id"
    t.integer "format"
    t.string "s3_bucket"
    t.string "s3_key"
    t.integer "encode_status", default: 0, null: false
    t.string "encode_job_id"
    t.datetime "deleted_at"
    t.datetime "datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url_string"
    t.index ["datetime"], name: "index_track_files_on_datetime"
    t.index ["deleted_at"], name: "index_track_files_on_deleted_at"
    t.index ["track_id"], name: "index_track_files_on_track_id"
  end

  create_table "track_infos", force: :cascade do |t|
    t.string "label_name"
    t.string "catalog"
    t.string "release_artist"
    t.string "track_title"
    t.string "track_artist"
    t.string "release_name"
    t.datetime "release_date"
    t.string "mix_name"
    t.string "remixer"
    t.string "track_time"
    t.string "barcode"
    t.string "isrc"
    t.string "genre"
    t.string "release_written_by"
    t.string "release_producer"
    t.string "track_publisher"
    t.string "track_written_by"
    t.string "track_produced_by"
    t.boolean "vocals_m"
    t.boolean "vocals_f"
    t.boolean "upbeat_drivind_energetic"
    t.boolean "sad_moody_dark"
    t.boolean "fun_playfull_quirky"
    t.boolean "sentimental_love"
    t.boolean "big_buildups_sweeps"
    t.boolean "celebratory_party_vibe"
    t.boolean "inspiring_uplifting"
    t.boolean "chill_mellow"
    t.text "lyrics"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "track_listen_progresses", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "track_id"
    t.integer "listen_progress", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "index_track_listen_progresses_on_track_id"
    t.index ["user_id"], name: "index_track_listen_progresses_on_user_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "title"
    t.string "uri"
    t.integer "release_id"
    t.integer "track_number"
    t.string "genre"
    t.string "isrc_code"
    t.string "sample_mp3_uri"
    t.string "waveform_image_uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
    t.integer "old_id"
    t.boolean "drip_source"
    t.string "artist"
    t.boolean "artist_as_string"
    t.integer "listened_count", default: 0
    t.string "uri_string"
    t.integer "track_info_id"
    t.string "sample_ogg_uri"
  end

  create_table "tracks_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "track_id"
    t.index ["track_id", "user_id"], name: "index_tracks_users_on_track_id_and_user_id", unique: true
    t.index ["track_id"], name: "index_tracks_users_on_track_id"
    t.index ["user_id", "track_id"], name: "index_tracks_users_on_user_id_and_track_id", unique: true
    t.index ["user_id"], name: "index_tracks_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "avatar"
    t.string "braintree_customer_id"
    t.datetime "birthdate"
    t.integer "gender"
    t.string "t_shirt_size"
    t.integer "subscription_type", default: 0
    t.string "provider"
    t.string "uid"
    t.date "subscription_started_at"
    t.string "address_city"
    t.string "last_name"
    t.integer "old_id"
    t.boolean "drip_source"
    t.string "image_uri"
    t.string "braintree_subscription_id"
    t.date "braintree_subscription_expires_at"
    t.integer "subscription_length", default: 0, null: false
    t.integer "current_playlist_id"
    t.integer "download_credits", default: 0, null: false
    t.string "address_zip"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_state"
    t.string "address_country"
    t.boolean "terms_and_conditions", default: false
    t.boolean "code_of_conduct", default: false
    t.string "profile_url"
    t.boolean "open_for_follow", default: false
    t.bigint "header_id"
    t.datetime "deleted_at"
    t.integer "onboarding_step", default: 0
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["header_id"], name: "index_users_on_header_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.integer "assigned_to"
    t.datetime "created_at", default: "2019-02-14 21:56:01", null: false
    t.datetime "updated_at", default: "2019-02-14 21:56:01", null: false
    t.index ["assigned_to"], name: "index_users_roles_on_assigned_to"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "videos", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.string "video_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0
    t.integer "shares_count", default: 0
  end

  add_foreign_key "billing_order_histories", "users"
  add_foreign_key "cancellations", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "users", "headers"
end
