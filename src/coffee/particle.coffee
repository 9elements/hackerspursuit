class Particle
  
  constructor: (type = null, position = null, pixel, staticIntro) ->
    switch type
      when 'func'
        dir =
          x: if Math.random() < 0.5 then 1 else -1
          y: if Math.random() < 0.5 then 1 else -1
        speed = Math.pow(Math.random()+MIN_SPEED,2)*MAX_SPEED
        power = {x:2,y:2}
        stauchung =
          x: Math.pow(Math.random()+MIN_SPEED,2)
          y: Math.pow(Math.random()+MIN_SPEED,2)
        if Math.random() > 0.5
          @func_in = (time) ->
            x: position.x
            y: stauchung.y * Math.pow(time,power.y) * dir.y * speed + position.y
        else
          @func_in = (time) ->
            x: stauchung.x * Math.pow(time,power.x) * dir.x * speed + position.x
            y: position.y
        @func_out = (time) ->
          x: stauchung.x * Math.pow(time,power.x) * dir.x * speed + position.x
          y: stauchung.y * Math.pow(time,power.y) * dir.y * speed + position.y

        @pos = position
        @pixel = pixel
        @staticIntro = staticIntro
  
  update: ->
    switch window.animationPhase
      when 'logo_in'
        @pos = @func_in(TIME) unless @staticIntro
      when 'type_in'
        if @staticIntro
          duration = window.animationPhaseEnd['type_in'].end
          current = window.FRAME/duration + 0.02
          @pixel[3] = current
      when 'pause'
        return
      when 'out'
        @pos = @func_out(TIME)
        # console.log 'update', @pixel[3]
        newValue = @pixel[3]*0.97 if @pixel[3] > 0
        @pixel = [
          @pixel[0]
          @pixel[1]
          @pixel[2]
          newValue
        ]

  
  draw: ->
    # CTX.globalCompositeOperation = "lighter"
    CTX.strokeStyle = 'rgba(0,255,0,255)'
    # console.log "rgba(#{@pixel[0]},#{@pixel[1]},#{@pixel[2]},#{@pixel[3]})" if @staticIntro
    CTX.fillStyle = "rgba(#{@pixel[0]},#{@pixel[1]},#{@pixel[2]},#{@pixel[3]})"
    CTX.fillRect @pos.x, @pos.y, PARTICLE_SIZE, PARTICLE_SIZE

window.Particle = Particle