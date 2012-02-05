class PImage
  
  max_particles_per_axis: 91

  grid:
    width: 0
    height: 0

  url: '/img/9pixelments.png'
  
  init: =>
    @image = document.createElement('img')
    @image.src = @url
    $(@image).load =>
      @pre_process()
  
  pre_process: ->
    CTX.drawImage($(@image).get(0), 0, 0)
    @img_data = CTX.getImageData(0,0,@image.width,@image.height)
    CTX.clearRect(0,0,CANVAS.width(),CANVAS.height())
    canvas_width = $('canvas').width()
    canvas_height = $('canvas').height()
    @img_offset =
      x: (Math.floor($('canvas').width()/2) - @image.width*window.PARTICLE_SIZE/2)
      y: (Math.floor($('canvas').height()/2) - @image.height*window.PARTICLE_SIZE/2)
    @createPixels()
  
  createPixels: ->
    # console.log 'ceratePixels', @img_data.data.length/4
    for i in [0..@img_data.data.length/4]
      index = i * 4
      if @img_data.data[index] is 0
        # console.log 'creating particle'
        point =
          x: (i % @image.width) * window.PARTICLE_SIZE + @img_offset.x
          y: Math.floor(i/@image.width) * window.PARTICLE_SIZE + @img_offset.y
        isStatic = true if Math.floor(i/@image.width) > 40
        pixel = [
          86
          96
          80
          if isStatic then 0 else 1
        ]
        window.PARTICLES.push new Particle 'func', point, pixel, isStatic
        

window.PImage = PImage