class TrackPresenter < SimpleDelegator

  def class
    __getobj__.class
  end
  
  def initialize(track, current_user = nil, browser)
    @track = track
    @current_user = current_user
    @browser = browser
    __setobj__(track)
    @is_sample = !(current_user && 
          current_user.cached_active_subscription? && 
          current_user.can_use_credits?)
  end

  def stream_uri
    __getobj__.stream_uri(is_sample, browser)
  end

  def download_uris
    return {} if is_sample
    __getobj__.download_uris
  end

  private

  attr_accessor :current_user, :track, :is_sample, :browser
end
