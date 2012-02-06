class PImage
  
  url: '/img/9pixelments.png'
  
  init: =>
    @image = document.createElement('img')
    @image.src = @url
    $(@image).load =>
      @pre_process()
      Intro.imageCenterOffset = @getImageCenter()
      # console.log 'imageCenterOffset', Intro.imageCenterOffset.x, Intro.imageCenterOffset.y

  pre_process: ->
    Intro.CTX.drawImage($(@image).get(0), 0, 0)
    @img_data = Intro.CTX.getImageData(0,0,@image.width,@image.height)
    Intro.CTX.clearRect(0,0,Intro.CANVAS.width(),Intro.CANVAS.height())
    @img_offset =
      x: (Math.floor($('canvas').width()/2) - @image.width*Intro.PARTICLE_SIZE/2)
      y: (Math.floor($('canvas').height()/2) - @image.height*Intro.PARTICLE_SIZE/2)
    @createPixels()
  

  getImageCenter: ->
    { x: @image.width/2, y: @image.height/2 }


  createPixels: ->
    for i in [0..@img_data.data.length/4]
      index = i * 4
      if @img_data.data[index] is 0
        point =
          x: (i % @image.width) * Intro.PARTICLE_SIZE + @img_offset.x
          y: Math.floor(i/@image.width) * Intro.PARTICLE_SIZE + @img_offset.y
        isStatic = true if Math.floor(i/@image.width) > 40
        pixel = [
          86
          96
          80
          if isStatic then 0 else 1
        ]
        Intro.PARTICLES.push new Particle 'func', point, pixel, isStatic
        # console.log point.x, point.y
        # return

window.PImage = PImage