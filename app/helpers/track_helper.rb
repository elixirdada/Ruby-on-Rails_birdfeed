module TrackHelper
  def formatted_track_time(track_time)
    return '-' if track_time.blank?

    mins_and_seconds_parts = []
    track_time.to_s.split(':').each do |part|
      mins_and_seconds_parts << part unless part.include?('-')
    end

    if mins_and_seconds_parts.length > 2 && mins_and_seconds_parts.first == '00'
      # Remove hours when they are present, we only care about mins and seconds
      mins_and_seconds_parts.shift
    end

    if mins_and_seconds_parts.length == 2
      # Some times are as xx:yy:zz +4918
      # This will remove the +4918 part
      mins_and_seconds_parts[1] = mins_and_seconds_parts[1].split(' ').first
    end
    mins_and_seconds_parts.join(':')
  end

  def formatted_artists_name(artists)
    return artists if artists.blank?

    return artists unless artists.split("&").length >= 2

    artists_array = artists.split("&")
    main_artist = artists_array.shift

    "#{main_artist} & #{artists_array.length} other#{'s' if artists_array.length >= 2}"
  end
end
