#$(document).on "page:change", ->
$ ->
  if window.location.hash is "#_=_"
    window.location.hash = ""
  jqtouch = $.jQTouch({})
