(function() {
  var $;
  $ = jQuery;
  $.fn.extend({
    pixelize: function(imageUrl) {
      return this.each(function() {
        var container;
        container = $(this);
        return $.getImageData({
          url: imageUrl,
          success: function(image) {
            var average, canvas, canvas_el, h, i, image_data, j, size, w, _ref, _ref2, _ref3, _ref4, _step, _step2;
            container.empty();
            canvas_el = $("<canvas id='canvas-profile' width='" + (image.width - 1) + "' height='" + (image.height - 1) + "'></canvas>");
            container.append(canvas_el);
            canvas = canvas_el.get(0).getContext('2d');
            canvas.drawImage(image, 0, 0, image.width, image.height);
            image_data = canvas.getImageData(0, 0, image.width, image.height);
            size = 4;
            for (w = 0, _ref = image.width - 1, _step = size; 0 <= _ref ? w <= _ref : w >= _ref; w += _step) {
              for (h = 0, _ref2 = image.height - 1, _step2 = size; 0 <= _ref2 ? h <= _ref2 : h >= _ref2; h += _step2) {
                average = (image_data.data[((image.height * h) + w) * 4] + image_data.data[((image.height * h) + w) * 4 + 1] + image_data.data[((image.height * h) + w) * 4 + 2]) / 3;
                for (i = 0, _ref3 = size - 1; 0 <= _ref3 ? i <= _ref3 : i >= _ref3; 0 <= _ref3 ? i++ : i--) {
                  for (j = 0, _ref4 = size - 1; 0 <= _ref4 ? j <= _ref4 : j >= _ref4; 0 <= _ref4 ? j++ : j--) {
                    if (!(w + j > image.width - 1 || h + i > image.height - 1)) {
                      image_data.data[((image.width * (h + i)) + w + j) * 4] = average;
                      image_data.data[((image.width * (h + i)) + w + j) * 4 + 1] = average + 20;
                      image_data.data[((image.width * (h + i)) + w + j) * 4 + 2] = average;
                    }
                  }
                }
              }
            }
            return canvas.putImageData(image_data, 0, 0);
          },
          error: function(xhr, text_status) {
            return console.log("Error loading profile image: " + text_status);
          }
        });
      });
    }
  });
}).call(this);
