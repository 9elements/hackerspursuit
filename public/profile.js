(function() {
  $(document).ready(function() {
    $('#canvas-container').pixelize($('#profileImage').text());
    return $('#canvas-container').show();
  });
}).call(this);
