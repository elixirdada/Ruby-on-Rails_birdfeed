$(document).on('turbolinks:load', () => {
  var player_page = $('body').hasClass('player_page');

  if (player_page) {
    switchPlayerView('bottom');
  } else {
    switchPlayerView('top');
  }

  $("body").on('click', '.jp-previous', function(){
    playPrevious();
  });

  $("body").on('click', '.jp-next', function(){
    playNext();
  });

  $("body").on('click', '.pp-previous', function(){
    playPrevious();
  });

  $("body").on('click', '.pp-next', function(){
    playNext();
  });

  $("body").on('click', "[class^='play-']", function(e){
    var sourceType = $(this).data('sourceType');
    var sourceId = $(this).data('sourceId');

    if (sourceType === 'release') {
      $("[class^='play-release-']").show().next('.jp-controls').css({'display': 'none'});
      $('.btn.play-release-' + sourceId).hide().next('.jp-controls').css({'display': 'inline-flex'});
    }

    playButton(this);
    return false;
  });

  updatePlayerState();

  var draggedBars = [
    ['.pp-volume-bar','.volume-bar-value','volume'],
    ['.pp-seek-bar','.pp-play-bar','progress']
  ]
  dragBars(draggedBars);

  timerAndLoadingForAudio(cpAudio);
  $(".lazy").Lazy({
    scrollDirection: 'vertical',
    effect: 'fadeIn',
    visibleOnly: true,
    effectTime: 2000,
  });
});
