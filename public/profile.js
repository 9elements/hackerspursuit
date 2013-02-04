(function() {

  $(document).ready(function() {
    $('#profile-image').load(function() {
      var canvas, canvas_el;
      canvas_el = $("<canvas id='canvas-profile' width='" + (this.width - 1) + "' height='" + (this.height - 1) + "'></canvas>");
      $('#canvas-container').append(canvas_el);
      canvas = canvas_el.get(0).getContext('2d');
      canvas.drawImage(this, 0, 0, this.width, this.height);
      $(canvas_el).pixelize(this.width, this.height);
      return $('#canvas-container').fadeIn();
    });
    $('#profile-image').attr('src', "/image/?url=" + ($('#profileImage').text()));
    return $('.badges-list li').hover(function() {
      return $("\#" + ($(this).attr('data-badge'))).toggle();
    });
  });

}).call(this);
