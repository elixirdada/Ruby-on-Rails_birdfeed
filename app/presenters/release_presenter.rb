class ReleasePresenter < SimpleDelegator
  include ActionView::Helpers::SanitizeHelper
  include ERB::Util

  def class
    __getobj__.class
  end

  def initialize(release, current_user = nil)
    @release = release
    @current_user = current_user
    __setobj__(release)
  end

  def meta_tags
    meta_tag = MetaTag.where(resource_type: 'release', resource_id: release.id).first

    return '' if __getobj__.facebook_img.nil?
    unless meta_tag
      meta_tag = MetaTag.new
      meta_tag.resource_type = 'release'
      meta_tag.resource_id = __getobj__.id
      meta_tag.meta_tags = <<-EOF
        <meta property="og:url"         content="#{ENV['BASE_URL']}/releases/#{release.id}" />
        <meta property="og:type"        content="music.album" />
        <meta property="og:title"       content="#{__getobj__.title}" />
        <meta property="og:description" content="#{h strip_tags(__getobj__.text)}" />
        <meta property="og:image"       content="#{URI.escape(__getobj__.facebook_img)}" />
      EOF
      meta_tag.save
    end
    meta_tag.meta_tags
  end

  def tracks
    release.tracks.order(track_number: :asc).map do |track|
      TrackPresenter.new(track, current_user, @browser)
    end
  end

  def signed_in?
    # boolean cast so we don't want to leak
    # out the current_user
    !!current_user
  end

  def user_allowed?
    signed_in? && release.user_allowed?(current_user)
  end

  def download_uris
    if user_allowed?
      __getobj__.download_uris
    else
      {}
    end
  end

  private

  attr_accessor :current_user, :release
end
