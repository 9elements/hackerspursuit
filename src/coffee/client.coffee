randOrd = ->
  Math.round(Math.random())-0.5

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

    socket.on "disconnect", ->
      $('#header-countwait').html("Trying to reconnect")
      $('#countwait').html("Pease stand by...")
      $('#view-game').hide()
      started = false


    socket.on "connect", ->
      id = socket.socket.sessionid
      $.getJSON "/user/auth-socket.json?id=#{id}", (data) =>
        startGame()
        return if loaded

        if data.success

          socket.on "question.new", (question) ->
            if !started
              $('#view-wait').hide()
              $('#view-game').fadeIn()
              setTimeout ->
                listEntry "System", "Navigate to <a href=\"/highscore\" target=\"_blank\">/highscore</a> for overall score"
              , 3000

              started = true
              loaded = true
            
            $('.selected').removeClass('selected')
            for answer in [1..4]
              $('#a' + answer).fadeIn('fast')
              
            $('#question').text("#{question.category}: #{question.text}")

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
            for entry in scoreboard
              listEntry = $('<li>').append(
                $('<a>').attr(href: "/profile/#{entry.userId}", target: "_blank").html("#{entry.points} #{entry.name.substring(0, 8)}"))
              $('#scoreboard').append listEntry
          
          socket.on "chat.msg", (result) ->
            listEntry result.name, result.msg

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
  
  $('.view-content').hide()
  connect()