$(document).on "click", ".playlist-item", ->

  # Trigger click on playlist play track
  if $(@).find('.playlist-play-track').length > 0
    $(@).find('.playlist-play-track').click()

  # Remove active status from other playlists
  $('.playlist-item').each ->
    $(@).removeClass('playlist-item-active')

  # Add active status to this track
  $(@).addClass("playlist-item-active")
