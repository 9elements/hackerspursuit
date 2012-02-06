class Particle
  
  constructor: (type = null, position = null, pixel, staticIntro) ->
    switch type
      when 'func'
        @dir =
          x: if Math.random() < 0.5 then 1 else -1
          y: if Math.random() < 0.5 then 1 else -1
        @speed = Math.pow(Math.random()+Intro.MIN_SPEED,2)*Intro.MAX_SPEED
        @power = {x:2,y:2}
        @stauchung =
          x: Math.pow(Math.random()+Intro.MIN_SPEED,2)
          y: Math.pow(Math.random()+Intro.MIN_SPEED,2)
        # if Math.random() > 0.5
        #   @func_in = @inVertical
        # else
        #   @func_in = @inHorizontal
        @func_in = @inBoth
        @func_out = @out
        @drawPosition =  @pos = position
        @pixel = pixel
        @staticIntro = staticIntro

  inVertical: ->
    # console.log "#{@stauchung.y} * #{Math.pow(Intro.TIME,@power.y)} * #{@dir.y} * #{@speed} + #{@pos.y} = #{@stauchung.y * Math.pow(Intro.TIME,@power.y) * @dir.y * @speed + @pos.y}"
    {
      x: @pos.x
      y: @stauchung.y * Math.pow(Intro.TIME,@power.y) * @dir.y * @speed + @pos.y
    }

  inHorizontal: ->
    # console.log "#{@stauchung.x} * #{Math.pow(Intro.TIME,@power.x)} * #{@dir.x} * #{@speed} + #{@pos.x} = #{@stauchung.x * Math.pow(Intro.TIME,@power.x) * @dir.x * @speed + @pos.x}"
    {
      x: @stauchung.x * Math.pow(Intro.TIME,@power.x) * @dir.x * @speed + @pos.x
      y: @pos.y
    }

  inBoth: ->
    # console.log "#{@stauchung.y} * #{Math.pow(Intro.TIME,@power.y)} * #{@dir.y} * #{@speed} + #{@pos.y} = #{@stauchung.y * Math.pow(Intro.TIME,@power.y) * @dir.y * @speed + @pos.y}"
    {
      x: @stauchung.x * Math.pow(Intro.TIME,@power.x) * @dir.x * @speed + @pos.x
      y: @stauchung.y * Math.pow(Intro.TIME,@power.y) * @dir.y * @speed + @pos.y
    }

  out: ->
    { 
      x: @stauchung.x * Math.pow(Intro.TIME,@power.x) * @dir.x * @speed + @pos.x
      y: @stauchung.y * Math.pow(Intro.TIME,@power.y) * @dir.y * @speed + @pos.y
    }

  rotate: ->
    rotationFactor = Math.sin(Intro.rotationFrame*0.03)
    delta_x = Intro.canvasCenter.x - @pos.x
    {
      x: Math.round(Intro.canvasCenter.x + delta_x * rotationFactor) - 3
      y: @pos.y
    }

  rotationOffset: ->
    rotatedPosition = @rotate()
    {
      x: @pos.x - rotatedPosition.x
      y: 0
    }

  waveOffset: ->
    offset = { x: 0, y: 0 }
    t = ((Intro.FRAME) * 4 + 200)
    t_delta = 40
    index = @pos.x + (@pos.y - 200) * 0.8
    if (t-t_delta) < index < (t+t_delta)
      delta = index - t
      offset =
        x: 0
        y: -(Math.pow(delta,2) * 0.002) + 3
    return offset

  rasterizeAlpha: (alpha) ->
    newAlpha = alpha * 100
    newAlpha = Math.floor(newAlpha/16) * 16
    return newAlpha/100


  update: =>
    @drawPosition =
      x: @pos.x
      y: @pos.y
    switch Intro.animationPhase
      when 'logo_in'
        @drawPosition = @func_in() unless @staticIntro
        # @drawPosition = @rotationOffset()
      when 'type_in'
        if @staticIntro
          @pixel[3] = Intro.FRAME/Intro.animationPhaseEnd['type_in'].end + 0.02
      when 'out'
        @drawPosition = @func_out()
        alpha = @pixel[3]*0.97 if @pixel[3] > 0
        @pixel = [
          @pixel[0]
          @pixel[1]
          @pixel[2]
          alpha
        ]
      when 'wave'
        if @staticIntro
          waveOffset = @waveOffset()
          @drawPosition.x -= waveOffset.x
          @drawPosition.y -= waveOffset.y
      when 'fade_out'
        @pixel[3] = @pixel[3] * 0.95

    if not @staticIntro and Intro.rotationFrame isnt null
      rotationOffset = @rotationOffset()
      # console.log "drawPosition: x: #{@drawPosition.x} y: #{@drawPosition.y} offset: x: #{rotationOffset.x} y: #{rotationOffset.y}"
      @drawPosition.x -= rotationOffset.x 
      @drawPosition.y -= rotationOffset.y
      # console.log "(#{Intro.rotationFrame})(#{@pos.x}, #{@pos.y}) x: #{@drawPosition.x} y: #{@drawPosition.y}"
  
  draw: =>
    Intro.CTX.strokeStyle = 'rgba(0,255,0,255)'
    Intro.CTX.fillStyle = "rgba(#{@pixel[0]},#{@pixel[1]},#{@pixel[2]},#{@rasterizeAlpha(@pixel[3])})"
    @drawPosition.x = Math.floor(@drawPosition.x/2) * 2
    @drawPosition.y = Math.floor(@drawPosition.y/2) * 2
    Intro.CTX.fillRect @drawPosition.x, @drawPosition.y, Intro.PARTICLE_SIZE, Intro.PARTICLE_SIZE

window.Particle = Particle