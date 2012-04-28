(function() {
  $(document).ready(function() {
    $('#canvas-container').pixelize($('#profileImage').text());
    $('#canvas-container').show();
    return $('.badges-list li').hover(function() {
      return $("\#" + ($(this).attr('data-badge'))).toggle();
    });
  });
}).call(this);
