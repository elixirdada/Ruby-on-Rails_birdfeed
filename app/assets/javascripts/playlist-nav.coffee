$(document).on "click", ".track-name-wrapper", ->
  $(@).find('a[data-source-type="release"]').trigger('click')
