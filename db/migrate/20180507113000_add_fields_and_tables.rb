class AddFieldsAndTables < ActiveRecord::Migration[5.1]
  def change


    create_table :downloads do |t|
      t.references :track
      t.references :user
      t.integer :format
      t.boolean :release, default: false
      
      t.timestamps
    end

    create_table :emails do |t|
      t.string :subject, null: false
      t.text :body_html
      t.text :body_text
      t.string :from, null: false
      t.string :image_uri
      t.string :title
      t.string :cta_link
      t.string :cta_text
      t.string :template, null: false
      t.string :category
      t.string :batch_id
      t.datetime :send_at, null: false
      t.datetime :deleted_at

      t.timestamps
    end
    
    create_table :emails_users do |t|
      t.references :email
      t.references :user
    end


    create_table :meta_tags do |t|
      t.string :meta_tags
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table :release_files do |t|
      t.references :release
      t.integer :format
      t.string :s3_bucket
      t.string :s3_key
      t.integer :encode_status, default: 0, null: false
      t.string :encode_job_id
      t.datetime :deleted_at
      t.datetime :datetime

      t.timestamps
    end
    add_index(:release_files, :datetime)
    add_index(:release_files, :deleted_at)

    create_table :topic_tags do |t|
      t.string :name, null: false
      t.string :description

      t.timestamps
    end

    create_table :topic_tags_topics do |t|
      t.references :topic
      t.references :topic_tag
    end

    create_table :track_files do |t|
      t.references :track
      t.integer :format
      t.string :s3_bucket
      t.string :s3_key
      t.integer :encode_status, default: 0, null: false
      t.string :encode_job_id
      t.datetime :deleted_at
      t.datetime :datetime

      t.timestamps
    end
    add_index(:track_files, :datetime)
    add_index(:track_files, :deleted_at)

    


    add_column :users, :old_id, :integer
    add_column :tracks, :old_id, :integer
    add_column :releases, :old_id, :integer
    add_column :topics, :old_id, :integer
    add_column :announcements, :old_id, :integer
    # add_column :emails, :old_id, :integer


    add_column :users, :drip_source, :boolean
    add_column :tracks, :drip_source, :boolean
    add_column :releases, :drip_source, :boolean


  end
end
