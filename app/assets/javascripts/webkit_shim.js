// iOS 11.3 Safari / macOS Safari 11.1 empty <input type="file"> XHR bug workaround.
// Replace empty File object with equivalent Blob in FormData, keeping its order, before sending it to server.
// Should work with IE10 and all other modern browsers.
// Because useragent value can be customized by WebView or etc., applying workaround code for all browsers.
// https://stackoverflow.com/questions/49614091/safari-11-1-ajax-xhr-form-submission-fails-when-inputtype-file-is-empty
// https://github.com/rails/rails/issues/32440
document.addEventListener('ajax:beforeSend', function(e) {
  var formData = e.detail[1].data
  if (!(formData instanceof window.FormData)) return
  if (!formData.keys) return // unsupported browser
  var newFormData = new window.FormData()
  Array.from(formData.entries()).forEach(function(entry) {
    var value = entry[1]
    if (value instanceof window.File && value.name === '' && value.size === 0) {
      newFormData.append(entry[0], new window.Blob([]), '')
    } else {
      newFormData.append(entry[0], value)
    }
  })
  e.detail[1].data = newFormData
})