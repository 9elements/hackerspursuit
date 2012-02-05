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
        if Math.random() > 0.5
          @func_in = @inVertical
        else
          @func_in = @inHorizontal
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

  out: ->
    { 
      x: @stauchung.x * Math.pow(Intro.TIME,@power.x) * @dir.x * @speed + @pos.x
      y: @stauchung.y * Math.pow(Intro.TIME,@power.y) * @dir.y * @speed + @pos.y
    }

  update: =>
    switch Intro.animationPhase
      when 'logo_in'
        @drawPosition = @func_in() unless @staticIntro
      when 'type_in'
        if @staticIntro
          @pixel[3] = Intro.FRAME/Intro.animationPhaseEnd['type_in'].end + 0.02
      when 'out'
        @drawPosition = @func_out()
        newValue = @pixel[3]*0.97 if @pixel[3] > 0
        @pixel = [
          @pixel[0]
          @pixel[1]
          @pixel[2]
          newValue
        ]
  
  draw: =>
    Intro.CTX.strokeStyle = 'rgba(0,255,0,255)'
    Intro.CTX.fillStyle = "rgba(#{@pixel[0]},#{@pixel[1]},#{@pixel[2]},#{@pixel[3]})"
    Intro.CTX.fillRect @drawPosition.x, @drawPosition.y, Intro.PARTICLE_SIZE, Intro.PARTICLE_SIZE

window.Particle = Particle