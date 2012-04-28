$(document).ready ->
  $('#canvas-container').pixelize($('#profileImage').text())
  $('#canvas-container').show()

  $('.badges-list li').hover ->
    $("\##{$(@).attr('data-badge')}").toggle()

