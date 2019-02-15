# Added to fix turbolinks anchor issue
# https://github.com/turbolinks/turbolinks/issues/75#issuecomment-244915109
linkTargetsAnchorOnSamePage = (link) ->
  href = link.getAttribute('href')

  return true if href.charAt(0) == '#'

  if href.match(new RegExp('^' + window.location.toString().replace(/#.*/, '') + '#'))
    return true
  else if href.match(new RegExp('^' + window.location.pathname + '#'))
    return true

  return false
  
$(document).on 'turbolinks:click', (event) ->
  if linkTargetsAnchorOnSamePage(event.target)
    $element = $(event.target.getAttribute('href'))
    $("html, body").animate({ scrollTop: $element.offset().top - 110 }, 500)
    return event.preventDefault()
