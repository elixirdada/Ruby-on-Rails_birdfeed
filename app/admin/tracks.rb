ActiveAdmin.register Track do
  # permit_params :title, :uri, :category_id, :pinned, :locked, :noteworthy, :see_to_all
  filter :title
  index do
    column :track_number
    column :title
    column :file, as: :file, label: "Track file (WAV Format)", input_html: { class: 'direct-upload' }
    column :artist_as_string
    column :artist
    actions do |release|
    end
  end

  form do |t|
    t.has_many :track_info, new_record: false, class: "directUpload" do |x|
      x.input :label_name
      x.input :catalog
      x.input :release_artist
      x.input :track_title
      x.input :track_artist
      x.input :release_name
      x.input :release_date, as: :date_time_picker
      x.input :mix_name
      x.input :remixer
      x.input :track_time
      x.input :barcode
      x.input :isrc
      x.input :genre
      x.input :release_written_by
      x.input :release_producer
      x.input :track_publisher
      x.input :track_written_by
      x.input :track_produced_by
      x.input :vocals_m
      x.input :vocals_f
      x.input :upbeat_drivind_energetic
      x.input :sad_moody_dark
      x.input :fun_playfull_quirky
      x.input :sentimental_love
      x.input :big_buildups_sweeps
      x.input :celebratory_party_vibe
      x.input :inspiring_uplifting
      x.input :chill_mellow
      x.input :lyrics
    end
  end

  member_action :encode_track, method: :get do
    TransloaditApi::EncodeTrack.new(resource).call
    redirect_to admin_release_path(resource.release.id), notice: "Encoding Release! This may take up to 10 minutes."
  end
end
