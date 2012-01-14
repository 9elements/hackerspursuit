$(document).ready ->

  socket_host = $('#server-host').text()
  socket_port = $('#server-port').text()

  ### Communication ###
  
  socket   = null
  started  = false

  startGame = ->
    $('#view-login').hide()
    $('#view-wait').fadeIn()
    
    $(document).keydown (event) ->
      key = if event.keyCode then event.keyCode else event.which
      
    $('#a1').click ->
      sendAnswer(1)
    
    $('#a2').click ->
      sendAnswer(2)
        
    $('#a3').click ->
      sendAnswer(3)
          
    $('#a4').click ->
      sendAnswer(4)
  
  connect = ->
    socket = io.connect(socket_host, { 'port': parseInt(socket_port) })
    socket.on "connect", ->
      id = socket.socket.sessionid
      $.getJSON "/user/auth-socket.json?id=#{id}", (data) =>
        startGame()
        if data.success

          socket.on "question.new", (question) ->
            if !started
              $('#view-wait').hide()
              $('#view-game').fadeIn()
              started = true
            
            $('.selected').removeClass('selected')
            for answer in [1..4]
              $('#a' + answer).fadeIn('fast')
              
            $('#question').html("#{question.category}: #{question.text}")
            $('#a1').html(question.a1)
            $('#a2').html(question.a2)
            $('#a3').html(question.a3)
            $('#a4').html(question.a4)
          
          socket.on "answer.locked", (answer) ->
            $('#' + answer).addClass("selected")
          
          socket.on "answer.twice", ->
            addAlert "Already selected an answer."
          
          socket.on "answer.over", ->
            addAlert "The time is over."    
            
          socket.on "question.countdown", (seconds) ->
            if started
              $('#countdown').html(seconds)
            else
              $('#countwait').html("Joining in #{seconds} seconds...")
            
          socket.on "question.wait", (result) ->
            scoreboard = result.scoreboard
            correct = result.correct
            
            if !started
              $('#countwait').html("Good luck!")
              
            $('#countdown').html('Over')
            $('#scoreboard li').remove()
            for entry in scoreboard
              listEntry = $('<li>').html("#{entry.name}: #{entry.points}")
              $('#scoreboard').append listEntry
              
            for answer in [1..4]
              $('#a' + answer).fadeOut() unless correct is "a#{answer}"
          
        else
          alert "Could not authenticate: #{data.error}"
      
  sendAnswer = (n) ->
    return unless socket?
    socket.emit('answer.set', { answer: n })
   
  ### Alerts and Notices ###
  
  addAlert = (msg) ->
    alertEntry = $('<li>').html("Alert: #{msg}").fadeIn().delay(3000).fadeOut()
    $('#alert').append alertEntry
      
  ### Views ###
  
  $('.view-content').hide()
  connect()