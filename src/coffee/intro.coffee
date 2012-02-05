class Intro

  @PARTICLE_SIZE = 2
  @MAX_SPEED = 0.8
  @MIN_SPEED = 0.05
  @animationPhase = 'logo_in'
  @TIME = 0
  @PARTICLES = []
  @animationPhaseEnd =
    'logo_in':
      start: -400
      end: 0
    'pause1':
      start: 0
      end: 60
    'type_in':
      start: 0
      end: 100
    'pause2':
      start: 0
      end: 60
    'out':
      start: 0
      end: 200

  constructor: (container) ->
    @container = container
    i = new PImage
    i.init()

  start: (callback) ->
    # console.log 'Intro#start', @
    @callback = callback
    @WIDTH = $(@container).width()
    @HEIGHT = $(@container).height()
    $(@container).css 'padding-bottom', 0
    @START = -300
    @PAUSE = 100
    @EXPLOSION_POWER = 7
    Intro.CANVAS = $("<canvas width='#{@WIDTH}' height='#{@HEIGHT}'></canvas>")
    Intro.CANVAS.appendTo $(@container)
    Intro.CTX = Intro.CANVAS.get(0).getContext('2d')
    Intro.FRAME = @START

    # start animation
    @INTERVAL = setInterval @main_loop, 1000/50
    
    
  main_loop: =>
    Intro.FRAME += 1
    nextEnd = Intro.animationPhaseEnd[Intro.animationPhase].end
    switch Intro.animationPhase
      when 'logo_in'
        if Intro.FRAME is nextEnd
          # console.log 'logo_in is over, switching to pause1'
          Intro.animationPhase = 'pause1'
          Intro.FRAME = Intro.animationPhaseEnd['pause1'].start
      when 'pause1'
        if Intro.FRAME is nextEnd
          # console.log 'switching to type_in'
          Intro.animationPhase = 'type_in'
          Intro.FRAME = Intro.animationPhaseEnd['type_in'].start
      when 'type_in'
        if Intro.FRAME is nextEnd
          # console.log 'switching to pause2'
          Intro.animationPhase = 'pause2'
          Intro.FRAME = Intro.animationPhaseEnd['pause2'].start
      when 'pause2'
        if Intro.FRAME is nextEnd
          # console.log 'switching to out'
          Intro.animationPhase = 'out'
          Intro.FRAME = Intro.animationPhaseEnd['out'].start
      when 'out'
        if Intro.FRAME is nextEnd
          # console.log 'end'
          clearInterval(@INTERVAL)
          @animationFinished()
    
    if Intro.FRAME < 1
      Intro.TIME = 0.06 * Math.pow(Intro.FRAME,2)
    else
      Intro.TIME = 2 + Math.log(Intro.FRAME) * @EXPLOSION_POWER
    
    Intro.CTX.clearRect(0,0,@WIDTH,@HEIGHT)
    for particle in Intro.PARTICLES
      particle.update()
      particle.draw()
  
  animationFinished: ->
    $(container).css 'padding-bottom', '20px'
    Intro.CANVAS.remove()
    @callback()

window.Intro = Intro