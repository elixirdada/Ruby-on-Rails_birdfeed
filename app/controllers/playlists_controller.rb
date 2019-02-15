class PlaylistsController < ApplicationController

  before_action :authenticate_user!, except: [:sync_playlist, :load]
  before_action :set_notifications, only: [:index, :show]

  def index
    @user = User.find params[:user_id]
    @playlists = @user.playlists.visible
  end

  def show
    @playlist = Playlist.find params[:id]
    @user = @playlist.user
    @playlists = @user.playlists.visible
  end

  def load
    tr = Release.published
        .by_roles(current_user.try(:roles).try(:pluck, :id))
        .includes(:tracks)
        .where.not(tracks: {id: nil})
        .first
        .tracks
        .first
    track = TrackPresenter.new( tr, nil, @browser )

    if current_user
      if current_user.current_playlist_id.present?
        if params[:playlist_id].present?
          playlist = Playlist.find params[:playlist_id]
          current_user.update_attributes(current_playlist_id: playlist.id)
        else
          playlist = current_user.current_playlist
        end
      else # initial load
        playlist = current_user.playlists.create(
            default: true,
            name: 'last listened')
        current_user.update_columns(current_playlist_id: playlist.id)
      end
    else

      render json: {
          tracks: [ track_as_json( track ) ]
        }
      return
    end

    tracks = playlist.tracks.map do |_track|
      track_presenter = TrackPresenter.new(_track, current_user, @browser)
      track_as_json( track_presenter )
    end

    if playlist.current_track.present?
      current_track_data = playlist.current_track.split(':')
      current_track = { index: current_track_data[0].to_i, time: current_track_data[1].to_i }
    else
      current_track = { index: 0, time: 0 }
    end

    no_playlists_view = nil

    if playlist.default? && current_user.playlists.count == 1
      no_playlists_view = render_to_string( partial: 'playlists/no_playlists_view' )
    elsif playlist.default?
      playlist = current_user.playlists.visible.last
      current_user.update_columns(current_playlist_id: playlist.id)
    end

    playlist_name_form = render_to_string(
        partial: 'playlists/change_name',
        locals: { playlist: playlist } )

    render json: { tracks: tracks,
                   current_track: current_track,
                   playlist_id: playlist.id,
                   playlist_name_form: playlist_name_form,
                   no_playlists_view: no_playlists_view
                  }
  end

  def new_playlist_view
  end

  def create
    @playlist = current_user.playlists.create(playlist_params)
    current_user.update_attributes(current_playlist_id: @playlist.id )
    redirect_back(fallback_location: root_path)
  end

  def update
    @playlist = Playlist.find params[:id]

    if @playlist.user_id == current_user.id
      @playlist.default = false
      current_user.playlists.create(default: true, name: 'last listened')
      @playlist.update_attributes(playlist_params)
    end
  end

  def add_to_playlist_view
    @source_type = params[:source_type]
    @source_id = params[:source_id]
    @track_id = params[:track_id]
  end

  def change_playlist_view
  end

  def sync_playlist
    return unless current_user

    if params[:default_playlist] == 'true'
      if !current_user.playlists.pluck(:default).include?(true)
        current_user.playlists.create(default: true, name: 'last listened')
      end

      playlist = current_user.playlists.where(default: true).first
      playlist.update_attributes(tracks_ids: params[:add_tracks_ids].join(','))
      current_user.update_attributes(current_playlist_id: playlist.id)
    elsif params[:target_playlist].present?
      playlist = current_user.playlists.find params[:target_playlist].to_i

      params[:add_tracks_ids].each do |id|
        playlist.tracks_ids = playlist.tracks_ids
                                      .to_s
                                      .split(',')
                                      .push(id)
                                      .join(',')
      end

      playlist.save
    elsif current_user.current_playlist.present?
      playlist = current_user.current_playlist

      if params[:add_tracks_ids].present?
        params[:add_tracks_ids].each do |id|
          playlist.tracks_ids = playlist.tracks_ids
                                        .to_s
                                        .split(',')
                                        .push(id)
                                        .join(',')
        end
      end

      if params[:delete_by_indices].present?
        params[:delete_by_indices].each do |i|
          tracks_ids = playlist.tracks_ids.to_s.split(',')
          tracks_ids.delete_at(i.to_i)
          playlist.tracks_ids = tracks_ids.join(',')
        end
      end

      if params[:current_track].present?
        playlist.current_track = "#{params[:current_track]}:#{params[:time] || 0}"
      end

      playlist.save
    end

    playlist_name_form = render_to_string(
        partial: 'playlists/change_name',
        locals: { playlist: playlist } )

    render json: { playlist_name_form: playlist_name_form }
  end

  private

    def playlist_params
      params.require(:playlist).permit(:name)
    end

    def track_as_json track
      { id: track.id,
        track_number: '%02i' % track.track_number,
        title: track.title,
        artists: track.artists,
        mp3: track.stream_uri,
        release_id: track.release_id,
        waveform: track.waveform_image_uri }
    end
end
