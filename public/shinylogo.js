(function() {
  $(window).load(function() {
    var canvas, context, cvShine, dataLogo, dataNext, eLogo, eShine, height, redraw, sHeight, sWidth, shine, width;
    canvas = $('canvas#shinylogo');
    context = canvas.get(0).getContext('2d');
    cvShine = $('canvas#canvas-shine');
    shine = cvShine.get(0).getContext('2d');
    eLogo = $('img#logo').get(0);
    eShine = $('img#logo-shine').get(0);
    width = eLogo.width;
    height = eLogo.height;
    sWidth = eShine.width;
    sHeight = eShine.height;
    context.drawImage(eLogo, 0, 0, width, height);
    dataLogo = context.getImageData(0, 0, width, height);
    dataNext = context.getImageData(0, 0, width, height);
    shine.translate(sWidth / 2, sHeight / 2);
    redraw = function() {
      var dataShine, h, i, offset, pixelPosition, shinePosition, w;
      shine.clearRect(-sWidth / 2, -sHeight / 2, sWidth, sHeight);
      shine.rotate(0.02);
      shine.drawImage(eShine, -sWidth / 2, -sHeight / 2, sWidth, sHeight);
      dataShine = shine.getImageData(0, 0, sWidth, sHeight);
      offset = ((sWidth / 2 - width / 2) + (sHeight / 2 - height / 2 - 20) * sWidth) * 4;
      for (w = 0; 0 <= width ? w <= width : w >= width; 0 <= width ? w++ : w--) {
        for (h = 0; 0 <= height ? h <= height : h >= height; 0 <= height ? h++ : h--) {
          pixelPosition = (h * width + w) * 4;
          shinePosition = offset + (h * sWidth + w) * 4;
          for (i = 0; i <= 2; i++) {
            dataNext.data[pixelPosition + i] = dataLogo.data[pixelPosition + i] + dataShine.data[shinePosition + 3] * 0.3;
          }
        }
      }
      return context.putImageData(dataNext, 0, 0);
    };
    return window.setInterval(function() {
      return redraw();
    }, 66);
  });
}).call(this);
