function fileUpload(fileInput) {
  fileInput.style.display = 'none'

  var uppy = Uppy.Core({
    id: fileInput.id,
  })
  .use(Uppy.FileInput, {
    target: fileInput.parentNode,
  })
  .use(Uppy.ProgressBar, {
    target: fileInput.parentNode,
    hideAfterFinish: false
  })
  .use(Uppy.StatusBar, {
    target: fileInput.parentNode,
    hideUploadButton: false,
    showProgressDetails: true,
    hideAfterFinish: true
  })
  .use(Uppy.AwsS3, {
    getUploadParameters: function (file) {
      return fetch('/presign?filename=' + file.name)
        .then(function (response) { return response.json() })
    }
  })

  var $fileInput   = $(fileInput)
  var $container   = $fileInput.siblings('.uppy-FileInput-container')
  var $submitBtns  = $fileInput.closest('form').find('input[type=submit]')
  var $progressBar = $fileInput.siblings('.uppy-ProgressBar')
  var $inputBtn    = $container.find('.uppy-FileInput-btn')

  uppy.on('upload', function(data) {
    [$submitBtns, $inputBtn].forEach(function ($btn) {
      $btn.prop('disabled', true).addClass('disabled')
    })
    $progressBar.show().find('.uppy-ProgressBar-inner').width(0)
    $container.find('span').remove()
    $container.append("<span>" + uppy.getFile(data.fileIDs).name + "</span>")
  })

  uppy.on('upload-success', function (file, data, uploadURL) {
    var hiddenInput = fileInput.parentElement.previousElementSibling.firstChild
    hiddenInput.value = data.location
  })

  uppy.on('complete', function (result) {
    [$submitBtns, $inputBtn].forEach(function ($btn) {
      $btn.prop('disabled', false).removeClass('disabled')
    })
    $progressBar.hide()
  })

  return uppy
}

$(document).ready(function(){
  document.querySelectorAll('.direct-upload').forEach(function (fileInput) {
    fileUpload(fileInput);
  })

  $('.formtastic.release').on('has_many_add:after', function(e, fieldset){
    var elements = document.querySelectorAll('.direct-upload');
    var lastElement = elements[elements.length - 1];
    fileUpload(lastElement);
  });
});
