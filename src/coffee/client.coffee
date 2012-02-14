randOrd = ->
  Math.round(Math.random())-0.5

ImageManipulator = class ImageManipulator
  constructor: (@image_el, @canvas)->
    @width = @image_el.width
    @height = @image_el.height

  pixelize: (size) =>         
    @image_data = @canvas.getImageData(0, 0, @width, @height)
    x_steps = parseInt @width / size
    
    for w in [0..(@width-1)] by size
      for h in [0..(@height-1)] by size
        average = (@image_data.data[((@height*h)+w)*4] + @image_data.data[((@height*h)+w)*4+1] + @image_data.data[((@height*h)+w)*4+2]) / 3
        for i in [0..(size-1)]
          for j in [0..(size-1)]
            unless w+j > @width-1 or h+i > @height-1
              @image_data.data[((@width*(h+i))+w+j)*4] = average
              @image_data.data[((@width*(h+i))+w+j)*4+1] = average + 20
              @image_data.data[((@width*(h+i))+w+j)*4+2] = average
    
    @canvas.putImageData(@image_data, 0, 0)

$(document).ready ->
  soundManager.url = "/swfs/"

  soundManager.onready ->
    soundManager.createSound
      id: 'wrong'
      url: ['/sounds/wrong.mp3', '/sounds/wrong.acc', '/sounds/wrong.ogg']
      autoLoad: true

    soundManager.createSound
      id: 'correct'
      url: ['/sounds/correct.mp3', '/sounds/correct.acc', '/sounds/correct.ogg']
      autoLoad: true

  ### Communication ###
  
  socket  = null
  started = false
  loaded  = false

  startGame = ->
    $('#view-login').hide()
    $('#view-wait').fadeIn()
  
  connect = ->
    socket = io.connect(host, { 'port': parseInt(port) })

    socket.on "profile.info", (profile) ->

      $('#profile-image').load ->
        canvas_el = $("<canvas id='canvas-profile' width='#{@.width-1}' height='#{@.height-1}'></canvas>")
        $('#canvas-container').append canvas_el
        canvas = canvas_el.get(0).getContext('2d')
        canvas.drawImage(@, 0, 0, @.width, @.height)
        im = new ImageManipulator(@, canvas, canvas_el)
        im.pixelize(4)
        $('#canvas-container').fadeIn()

      $('#profile-image').attr('src', "/image/#{profile.id}")

    socket.on "disconnect", ->
      $('#header-countwait').html("Trying to reconnect")
      $('#countwait').html("Pease stand by...")
      $('#view-game, #view-prepare, #view-chat').hide()
      $('.display').removeClass('stripes')
      $('#view-wait').fadeIn()
      started = false

    socket.on "connect", ->
      id = socket.socket.sessionid
      $.getJSON "/user/auth-socket.json?id=#{id}", (data) =>
        startGame()
        return if loaded

        if data.success

          socket.on "question.prepare", (question) ->
            $('.display').removeClass('stripes')

            unless started
              $('#view-wait').hide()
              $('#view-chat').fadeIn()
              setTimeout ->
                listEntry "System", "Navigate to <a href=\"/highscore\" target=\"_blank\">/highscore</a> for overall score"
              , 3000

              started = true
              loaded = true

            $('#question-category').text("Next question is about #{question.category}")
            $('#question-author').text("by #{question.createdBy}")

            $('#view-game').hide()
            $('#view-prepare').fadeIn()
            

          socket.on "question.new", (question) ->
            return unless started

            $('#view-prepare').hide()
            $('.display').addClass('stripes')
            $('#view-game').fadeIn()
            
            $('.selected').removeClass('selected')
            for answer in [1..4]
              $('#a' + answer).fadeIn('fast')
              
            $('#question').text("#{question.text}")

            keys = [1..4]
            keys.sort randOrd

            $('#a1').attr("data-answer", keys[0]).removeClass("selected").text(question['a' + keys[0]])
            $('#a2').attr("data-answer", keys[1]).removeClass("selected").text(question['a' + keys[1]])
            $('#a3').attr("data-answer", keys[2]).removeClass("selected").text(question['a' + keys[2]])
            $('#a4').attr("data-answer", keys[3]).removeClass("selected").text(question['a' + keys[3]])
          
          socket.on "answer.correct", (answer) ->
            console.log answer
            $('ul#answers li div[data-answer=' + answer + ']').addClass("selected")
            soundManager.play "correct"
          
          socket.on "answer.wrong", (answer) ->
            $('ul#answers li div[data-answer=' + answer + ']').addClass("selected")
            soundManager.play "wrong"
          
          socket.on "answer.twice", ->
            addAlert "You already selected an answer."
          
          socket.on "answer.over", ->
            addAlert "Time is over."    
            
          socket.on "question.countdown", (seconds) ->
            if started
              $('#countdown').html(seconds)
            else
              $('#countwait').html("JOINING IN #{seconds} SECONDS...")
          
          socket.on "scoreboard", (scoreboard) ->
            $('#scoreboard li').remove()
            rank = 0
            for entry in scoreboard
              rank += 1
              if rank < 11
                listEntry = $('<li>').append(
                  $('<a>').attr(href: "/profile/#{entry.userId}", target: "_blank").html("#{entry.points} #{entry.name.substring(0, 8)}"))
                $('#scoreboard').append listEntry
          
          socket.on "chat.msg", (result) ->
            listEntry result.name, result.msg
          
          socket.on "badge.new", (badge) ->
            if badge.badge == 'rampage'
              addAlert "#{badge.name} is on a rampage"
            if badge.badge == 'epic'
              addAlert "#{badge.name} knowledge is epic"
            if badge.badge == "godmode"
              addAlert "#{badge.name} is on godmode"
            if badge.badge == "pawned"
              addAlert "#{badge.name} pawned"
            if badge.badge == "monsterpawned"
              addAlert "#{badge.name} monsterpawned"
            if badge.badge == "failed"
                addAlert "#{badge.name} failed"
            if badge.badge == "epicfail"
              addAlert "#{badge.name} failed epic"


          socket.on "question.wait", (result) ->
            correct = result.correct
            
            if !started
              $('#countwait').html("Good luck!")
            $('#countdown').html("Over")
              
            for answer in [1..4]
              $('ul#answers li div[data-answer=' + answer + ']').fadeOut() unless correct is "a#{answer}"
          
        else
          alert "Could not authenticate: #{data.error}"
      
  sendAnswer = (n) ->
    return unless socket?
    socket.emit('answer.set', { answer: n })
   
  ### Alerts and Notices ###

  listEntry = (name, msg) ->
    message = $('<li>').html("<div class='message-wrapper'><span class='name'>#{name}:</span> #{msg}</div>")
    $('#messages').prepend(message)
    setTimeout ->
      message.css('height', '28px')
      if $('#messages li').length > 30
        $('#messages li:last-child').remove()
    , 1
  
  addAlert = (msg) ->
    listEntry "System", msg

  ### Buttons ###

  $(document).keydown (event) ->
    key = if event.keyCode then event.keyCode else event.which
        
  $('#a1, #a2, #a3, #a4').click ->
    sendAnswer($(this).attr("data-answer"))

  ### Chat ###

  $('#chat-form').bind 'submit', (e) ->
    e.preventDefault()
    return unless socket?
    message = $('#chat-msg').val()
    $('#chat-msg').val("")
    socket.emit('chat.msg', { content: message })
      
  ### Views ###
  
  $('#view-game, #view-prepare, #header-countwait, #view-chat').hide()

  ### intro ###

  $('.view-content .view-wait').show()

  intro = new Intro $('.display')
  intro.start =>
    $('#header-countwait').show()

    ### start game ###
    connect()
