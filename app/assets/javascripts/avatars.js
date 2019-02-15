var AvatarCropper,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

$(document).on('turbolinks:load', function() {
  return new AvatarCropper();
});

AvatarCropper = (function() {
  function AvatarCropper() {
    this.updatePreview = bind(this.updatePreview, this);
    this.update = bind(this.update, this);
    $('#cropbox').Jcrop({
      aspectRatio: 1,
      setSelect: [0, 0, 600, 600],
      onSelect: this.update,
      onChange: this.update
    });
  }

  AvatarCropper.prototype.update = function(coords) {
    $('#user_crop_x').val(coords.x);
    $('#user_crop_y').val(coords.y);
    $('#user_crop_w').val(coords.w);
    $('#user_crop_h').val(coords.h);
    return this.updatePreview(coords);
  };

  AvatarCropper.prototype.updatePreview = function(coords) {
    return $('#preview').css({
      width: Math.round(100 / coords.w * $('#cropbox').width()) + 'px',
      height: Math.round(100 / coords.h * $('#cropbox').height()) + 'px',
      marginLeft: '-' + Math.round(100 / coords.w * coords.x) + 'px',
      marginTop: '-' + Math.round(100 / coords.h * coords.y) + 'px'
    });
  };

  return AvatarCropper;

})();