$(document).ready ->
  $('#profile-image').load ->
    canvas_el = $("<canvas id='canvas-profile' width='#{@.width-1}' height='#{@.height-1}'></canvas>")
    $('#canvas-container').append canvas_el
    canvas = canvas_el.get(0).getContext('2d')
    canvas.drawImage(@, 0, 0, @.width, @.height)
    $(canvas_el).pixelize(@.width, @.height)
    $('#canvas-container').fadeIn()

  $('#profile-image').attr('src', "/image/?url=#{$('#profileImage').text()}")

  $('.badges-list li').hover ->
    $("\##{$(@).attr('data-badge')}").toggle()

