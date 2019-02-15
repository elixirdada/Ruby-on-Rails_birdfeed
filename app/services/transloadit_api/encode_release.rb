module TransloaditApi
  class EncodeRelease
    require 'transloadit'
    attr_reader :tracks, :transloadit_client, :release, :steps

    def initialize(release)
      @transloadit_client = TRANSLOADIT
      @release = release
      @tracks = release.tracks
      @steps = []
    end

    def call
      return if !release.tracks.exists? || release.catalog.blank? || release.encode_status == 'pending'
      release.pending!

      if release.assembly_complete?
        check_for_pending_tracks
      else
        tracks.each do |t|
          encode_track(t)
        end
      end

      ['aiff', 'flac', 'mp3', 'wav'].each do |format|
        source = []
        release.tracks.each do |t|
          source << "#{format}_#{t.id}"
        end
        steps << transloadit_client.step("zip_collection_#{format}", '/file/compress', {
            format: 'zip',
            file_layout: 'simple',
            use: {steps: source,
                  bundle_steps: true }
          })
        steps << transloadit_client.step("store_zip_collection_#{format}", '/s3/store', {
          key: ENV.fetch('S3_ENCODING_KEY'),
          secret: ENV.fetch('S3_ENCODING_SECRET'),
          bucket: ENV.fetch('S3_ENCODING_BUCKET_NAME'),
          bucket_region: ENV.fetch('S3_ENCODING_REGION'),
          use: "zip_collection_#{format}",
          path: "/#{release.catalog}/#{release.id}/${unique_prefix}/#{release.title.parameterize.underscore}.zip"
        })
      end

      assembly = transloadit_client.assembly(steps: steps)
      response = assembly.create!
      response.reload_until_finished!
      process_response response

    end

    def check_for_pending_tracks
      release.tracks.each do |t|
        if t.track_files.count < 9
          t.track_files.destroy_all if t.track_files.count > 0
          encode_track(t)
        else
          ['aiff', 'flac', 'mp3', 'wav'].each do |format|
            steps << transloadit_client.step("#{format}_#{t.id}", '/http/import', {
              url: t.track_files.find_by(format: "#{format}").url_string
            })
          end
        end
      end
    end

    def encode_track(t)
      steps << transloadit_client.step("import_track_#{t.id}", '/http/import', {
        url: t.uri.url
      })

      steps << transloadit_client.step("waveform_#{t.id}", '/audio/waveform', {
        use: "import_track_#{t.id}",
        format: 'json',
        ffmpeg_stack: 'v3.3.3',
        result: true
      })

      steps << transloadit_client.step("sample_ogg_#{t.id}", '/audio/loop', {
        use: "import_track_#{t.id}",
        preset: 'ogg',
        duration: 30.0,
        ffmpeg_stack: 'v3.3.3',
        result: true
      })

      steps << transloadit_client.step("sample_mp3_#{t.id}", '/audio/loop', {
        use: "import_track_#{t.id}",
        preset: 'mp3',
        duration: 30.0,
        ffmpeg_stack: 'v3.3.3',
        result: true
      })

      steps << transloadit_client.step("store_#{t.id}_waveform", '/s3/store', {
        key: ENV.fetch('S3_ENCODING_KEY'),
        secret: ENV.fetch('S3_ENCODING_SECRET'),
        bucket: ENV.fetch('S3_ENCODING_BUCKET_NAME'),
        bucket_region: ENV.fetch('S3_ENCODING_REGION'),
        use: "waveform_#{t.id}",
        path: "/#{release.catalog}/#{t.isrc_code}/sample/${unique_prefix}/#{t.title.parameterize.underscore}"
      })

      steps << transloadit_client.step("store_#{t.id}_samples", '/s3/store', {
        key: ENV.fetch('S3_ENCODING_KEY'),
        secret: ENV.fetch('S3_ENCODING_SECRET'),
        bucket: ENV.fetch('S3_ENCODING_BUCKET_NAME'),
        bucket_region: ENV.fetch('S3_ENCODING_REGION'),
        use: ["sample_ogg_#{t.id}", "sample_mp3_#{t.id}"],
        path: "/#{release.catalog}/#{t.isrc_code}/sample/${unique_prefix}/#{t.title.parameterize.underscore}"
      })

      steps << transloadit_client.step("ogg_#{t.id}", '/audio/encode', {
        use: "import_track_#{t.id}",
        preset: 'ogg',
        bitrate: 64000,
        ffmpeg_stack: 'v3.3.3',
        result: true
      })

      steps << transloadit_client.step("mp3_#{t.id}", '/audio/encode', {
        use: "import_track_#{t.id}",
        preset: 'mp3',
        ffmpeg_stack: 'v3.3.3',
        result: true
      })

      steps << transloadit_client.step("wav_#{t.id}", '/audio/encode', {
        use: "import_track_#{t.id}",
        preset: 'wav',
        ffmpeg_stack: 'v3.3.3',
        result: true
      })

      steps << transloadit_client.step("flac_#{t.id}", '/audio/encode', {
        use: "import_track_#{t.id}",
        preset: 'flac',
        ffmpeg_stack: 'v3.3.3',
        result: true
      })

      steps << transloadit_client.step("aiff_#{t.id}", '/audio/encode', {
        use: "import_track_#{t.id}",
        ffmpeg: {
                  "write_id3v1": 1,
                  "write_id3v2": 1,
                  "id3v2_version": 3,
                  "f": "aiff"
                },
        ffmpeg_stack: 'v3.3.3',
        result: true
      })

      ['aiff', 'flac', 'mp3', 'wav'].each do |format|
        steps << transloadit_client.step("zip_#{format}_#{t.id}", '/file/compress', {
          format: 'zip',
          file_layout: 'simple',
          use: "#{format}_#{t.id}"
        })
        steps << transloadit_client.step("store_zip_#{format}_#{t.id}", '/s3/store', {
          key: ENV.fetch('S3_ENCODING_KEY'),
          secret: ENV.fetch('S3_ENCODING_SECRET'),
          bucket: ENV.fetch('S3_ENCODING_BUCKET_NAME'),
          bucket_region: ENV.fetch('S3_ENCODING_REGION'),
          use: "zip_#{format}_#{t.id}",
          path: "/#{release.catalog}/#{t.isrc_code}/${unique_prefix}/#{t.title.parameterize.underscore}.zip"
        })
      end

      ['aiff', 'flac', 'mp3', 'wav', 'ogg'].each do |format|
        steps << transloadit_client.step("store_#{t.id}_#{format}", '/s3/store', {
          key: ENV.fetch('S3_ENCODING_KEY'),
          secret: ENV.fetch('S3_ENCODING_SECRET'),
          bucket: ENV.fetch('S3_ENCODING_BUCKET_NAME'),
          bucket_region: ENV.fetch('S3_ENCODING_REGION'),
          use: "#{format}_#{t.id}",
          path: "/#{release.catalog}/#{t.isrc_code}/${unique_prefix}/#{t.title.parameterize.underscore}.#{format}"
        })
      end
    end

    def process_response(response)
      if !response.error? && response.completed?
        ['aiff', 'flac', 'mp3', 'wav'].each do |target|
          if ReleaseFile.find_by(release: release, format: "#{target}")
            ReleaseFile.find_by(release: release, format: "#{target}").update(url_string: response['results']["zip_collection_#{target}"][0]['ssl_url'])
          else
            ReleaseFile.create(release: release,
                               format: "#{target}",
                               encode_status: :complete,
                               url_string: response['results']["zip_collection_#{target}"][0]['ssl_url'])
          end
        end
        release.tracks.each do |t|
          if t.track_files.count < 9
            t.update(waveform_image_uri: response['results']["waveform_#{t.id}"][0]['ssl_url'],
                     sample_mp3_uri: response['results']["sample_mp3_#{t.id}"][0]['ssl_url'],
                     sample_ogg_uri: response['results']["sample_ogg_#{t.id}"][0]['ssl_url'])
            ['aiff', 'flac', 'mp3', 'wav'].each do |target|
              TrackFile.create(track: t,
                               format: "zip_#{target}",
                               encode_status: :complete,
                               url_string: response['results']["zip_#{target}_#{t.id}"][0]['ssl_url'])
            end
            ['aiff', 'flac', 'mp3', 'wav', 'ogg'].each do |k|
              TrackFile.create(track: t,
                               format: k,
                               encode_status: :complete,
                               url_string: response['results']["#{k}_#{t.id}"][0]['ssl_url'])
            end
          end
        end
        release.update(assembly_id: response[:assembly_id], assembly_complete: true, encode_status: 'complete')
      else
        release.update(assembly_id: response[:assembly_id], assembly_complete: false, encode_status: 'failed')
      end
    end
  end
end
