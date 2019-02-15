class RaterController < ApplicationController
  include Helpers

  def create
    if user_signed_in?
      obj = params[:klass].classify.constantize.find(params[:id])
      obj.rate params[:score].to_f, current_user, params[:dimension]
      track = Track.find(obj.id)
      release = track.release
      rates = Rate.where(rater_id: current_user.id, rateable_id: release.id, rateable_type:'Release')
      if rates.any?
        rate = rates.first
      else
        obj = Release.find(release.id)
        rate = obj.rate 1.0, current_user, "main"
      end

      stars = 0
      count = 0

      release.tracks.each do |_track|
        _rates = Rate.where(rater_id: current_user.id, rateable_id: _track.id, rateable_type:'Track')

        if _rates.any?
          _rate = _rates.first
          stars += _rate.stars
          count += 1
        end
      end
      if count > 0
        stars /= count
      end

      rates = Rate.where(rater_id: current_user.id, rateable_id: release.id, rateable_type:'Release')
      if rates.any?
        rate = rates.first
      end
      rate.stars = stars
      rate.save

      rating_caches = RatingCache.where(cacheable_type: "Release", cacheable_id: release.id)

      if rating_caches.any?
        rating_cache = rating_caches.first
      end

      rates = Rate.where(rateable_id: release.id, rateable_type:'Release')

      if rates.any?
        _stars = 0

        rates.each do |_rate| 
          _stars += _rate.stars;
        end
      end

      _stars /= rates.length
      rating_cache.avg = _stars;
      rating_cache.save
      templates = render(
          :template => "tracks/tracks_star", 
          :locals => { :track => track, :release => release }, 
          :layout => false)    
      _templates = templates.split('<hr class="split-line">')

      @rating = Rate.where(
          rater_id: current_user.id, 
          rateable_id: track.id, 
          rateable_type: 'Track')
      user_track_rate = @rating.any? ? @rating.first.stars : 0
    
      ActionCable.server.broadcast 'tracks',
        track_template: _templates.first,
        release_template: _templates.second,
        track_id: track.id, 
        release_id: release.id,
        user_track_rate: user_track_rate
        return
    else
      render :json => false
    end
  end
end
