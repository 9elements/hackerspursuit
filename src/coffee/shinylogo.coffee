$(window).load ->
  canvas   = $('canvas#shinylogo')
  context  = canvas.get(0).getContext('2d')
  
  cvShine  = $('canvas#canvas-shine')
  shine    = cvShine.get(0).getContext('2d')
  
  eLogo    = $('img#logo').get(0)
  eShine   = $('img#logo-shine').get(0)
  
  width    = eLogo.width
  height   = eLogo.height
  
  sWidth   = eShine.width
  sHeight  = eShine.height

  # Get Image Data

  context.drawImage(eLogo, 0, 0, width, height)
  dataLogo = context.getImageData(0, 0, width, height)
  dataNext = context.getImageData(0, 0, width, height)

  shine.translate(sWidth / 2, sHeight / 2)

  redraw = ->
    shine.clearRect(- sWidth / 2, - sHeight / 2, sWidth, sHeight)
    shine.rotate(0.02)
    shine.drawImage(eShine, - sWidth / 2, - sHeight / 2, sWidth, sHeight)
    
    dataShine = shine.getImageData(0, 0, sWidth, sHeight)

    offset = ((sWidth / 2 - width / 2) + (sHeight / 2 - height / 2 - 20) * sWidth) * 4

    for w in [0..width]
      for h in [0..height]
        pixelPosition = (h * width + w) * 4
        shinePosition = offset + (h * sWidth + w) * 4
        dataNext.data[pixelPosition + i] = dataLogo.data[pixelPosition + i] + dataShine.data[shinePosition + 3] * 0.3 for i in [0..2]

    context.putImageData(dataNext, 0, 0)

  window.setInterval ->
    redraw()
  , 66