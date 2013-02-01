(function() {
  var $;

  $ = jQuery;

  $.fn.extend({
    pixelize: function(width, height) {
      var average, canvas, h, i, image_data, j, size, w, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3;
      canvas = this.get(0).getContext('2d');
      image_data = canvas.getImageData(0, 0, width, height);
      size = 4;
      for (w = _i = 0, _ref = width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; w = _i += size) {
        for (h = _j = 0, _ref1 = height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; h = _j += size) {
          average = (image_data.data[((width * h) + w) * 4] + image_data.data[((width * h) + w) * 4 + 1] + image_data.data[((width * h) + w) * 4 + 2]) / 3;
          for (i = _k = 0, _ref2 = size - 1; 0 <= _ref2 ? _k <= _ref2 : _k >= _ref2; i = 0 <= _ref2 ? ++_k : --_k) {
            for (j = _l = 0, _ref3 = size - 1; 0 <= _ref3 ? _l <= _ref3 : _l >= _ref3; j = 0 <= _ref3 ? ++_l : --_l) {
              if (!(w + j > width - 1 || h + i > height - 1)) {
                image_data.data[((width * (h + i)) + w + j) * 4] = average;
                image_data.data[((width * (h + i)) + w + j) * 4 + 1] = average + 20;
                image_data.data[((width * (h + i)) + w + j) * 4 + 2] = average;
              }
            }
          }
        }
      }
      return canvas.putImageData(image_data, 0, 0);
    }
  });

}).call(this);
