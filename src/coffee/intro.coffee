class Intro

  @PARTICLE_SIZE = 2
  @MAX_SPEED = 0.8
  @MIN_SPEED = 0.05
  @animationPhase = 'logo_in'
  # @animationPhase = 'type_in'
  @TIME = 0
  @PARTICLES = []
  animationPhases: ['type_in', 'wave', 'pause3', 'fade_out'] # 'out']
  # animationPhases: ['wave', 'pause3', 'out']
  @animationPhaseEnd:
    'logo_in':
      start: -400
      end: 0
    'pause1':
      start: 0
      end: 30
    'type_in':
      start: 0
      end: 100
    'pause2':
      start: 0
      end: 60
    'wave':
      start: 0
      end: 80
    'pause3':
      start: 0
      end: 30
    'out':
      start: 0
      end: 180
    'fade_out':
      start: 0
      end: 150
  @rotationFrame: 16

  constructor: (container) ->
    @container = container
    Intro.canvasCenter =
      x: $(@container).width()/2
      y: $(@container).height()/2
    i = new PImage
    i.init()

  start: (callback) ->
    # console.log 'Intro#start', @
    @callback = callback
    @WIDTH = $(@container).width()
    @HEIGHT = $(@container).height()
    @START = -150
    # @START = 0
    @PAUSE = 100
    @EXPLOSION_POWER = 7
    Intro.CANVAS = $("<canvas id='canvas-intro' width='#{@WIDTH}' height='#{@HEIGHT}'></canvas>")
    Intro.CANVAS.appendTo $(@container)
    Intro.CTX = Intro.CANVAS.get(0).getContext('2d')
    Intro.FRAME = @START

    # start animation
    @INTERVAL = setInterval @main_loop, 1000/50
    
    
  main_loop: =>
    Intro.FRAME += 1
    unless Intro.rotationFrame is null
      Intro.rotationFrame += 1
    nextEnd = Intro.animationPhaseEnd[Intro.animationPhase].end
    if Intro.FRAME is nextEnd
      if Intro.animationPhase is 'fade_out'
        clearInterval @INTERVAL
        @animationFinished()
        return 
      if Intro.animationPhase is 'wave'
        Intro.rotationFrame = null
      Intro.animationPhase = @animationPhases.shift()
      # console.log 'switching to', Intro.animationPhase
      Intro.FRAME = Intro.animationPhaseEnd[Intro.animationPhase].start

    if Intro.FRAME < 1
      Intro.TIME = 0.06 * Math.pow(Intro.FRAME,2)
    else
      Intro.TIME = 2 + Math.log(Intro.FRAME) * @EXPLOSION_POWER
    
    Intro.CTX.clearRect(0,0,@WIDTH,@HEIGHT)
    for particle in Intro.PARTICLES
      particle.update()
      particle.draw()
  
  animationFinished: ->
    Intro.CANVAS.remove()
    @callback()

window.Intro = Intro

intro = new Intro $('.display')
intro.start =>
  $('#view-login').fadeIn()
