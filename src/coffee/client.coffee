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
  kicked = false

  progress_starter = false
  progess_dna = false
  ownUserId = null
  badgeQueue = []
  displayingBadge = false

  startGame = ->
    $('#view-login').hide()
    $('#view-wait').fadeIn()

  connect = ->
    socket = io.connect(host, { 'port': parseInt(port) })

    socket.on "profile.info", (profile) ->
      $('#profile-image').load ->
        return if $('#canvas-container canvas').length > 0
        canvas_el = $("<canvas id='canvas-profile' width='#{@.width-1}' height='#{@.height-1}'></canvas>")
        $('#canvas-container').append canvas_el
        canvas = canvas_el.get(0).getContext('2d')
        canvas.drawImage(@, 0, 0, @.width, @.height)
        $(canvas_el).pixelize(@.width, @.height)
        $('#canvas-container').fadeIn()

      $('#profile-image').attr('src', "/image/?url=#{profile.profileImage}")

      $('#profile-name').text(profile.name.substring(0, 8))

      ownUserId = profile.id


    socket.on "scoreboard", (scoreboard) ->
      $('#scoreboard li').remove()
      rank = 0
      for entry in scoreboard
        rank += 1
        if rank < 11
          listEntry = $('<li>').append(
            $('<a>').attr(href: "/profile/#{entry.userId}", target: "_blank").html("#{entry.points} #{entry.name.substring(0, 8)}"))
          $('#scoreboard').append listEntry
        else
          if entry.userId == ownUserId
            listEntry = $('<li>').css('padding-left', '24px').css('margin', '8px 0px').html(".<br />.<br />")
            $('#scoreboard').append listEntry
            listEntry = $('<li>').append(
              $('<a>').attr(href: "/profile/#{entry.userId}", target: "_blank").html("#{entry.points} #{entry.name.substring(0, 8)}"))
            $('#scoreboard').append listEntry

    socket.on "chat.msg", (result) ->
      listEntry result.name, result.msg

    socket.on "badge.new", (badge) ->
      addBadge badge

    socket.on "progress.starter", (percent) ->
      unless progress_starter == true
        progress_starter = true
        $('#progress-starter').fadeIn()

      $('#bar-starter').css('width', "#{percent}%")


    socket.on "progress.dna", (dnaData) ->
      if progress_starter == true
        progress_starter = false
        progress_dna = true
        $('#progress-starter').fadeOut ->
          $('#progress-dna').fadeIn()
      else if progess_dna == false
        progess_dna = true
        $('#progress-dna').fadeIn()

      for progress in dnaData
        $("#bar-#{progress.name}").css('width', "#{progress.progress}%")


    socket.on "disconnect", ->
      unless kicked
        $('#header-countwait').html("Trying to reconnect")
        $('#countwait').html("Pease stand by...")
        $('#view-game, #view-prepare').hide()
        $('#chat-msg, .caption').css('display', 'none')
        $('.chat').css('background-color', '#92a486')
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

            unless started
              $('#view-wait').hide()
              $('#view-game').fadeIn()
              $('.display').addClass('stripes')
              $('#canvas-container').fadeIn()

              # Display chat
              i = 0
              step = 0
              while i < 800
                if step % 2 == 0 then color = '#e4f9d7' else color = '#92a486'
                do (color) ->
                  window.setTimeout ->
                    $('.chat').css('background-color', color)
                  , i
                step += 1
                i += Math.random() * 100

              window.setTimeout ->
                $('.chat').css('background-color', '#e4f9d7')
                $('#chat-msg').css('display', 'inline-block')
                $('.caption').css('display', 'inline-block')
              , (i+100)

              setTimeout ->
                listEntry "System", "Navigate to <a href=\"/highscore\" target=\"_blank\">/highscore</a> for overall score"
              , 3000

              started = true
              loaded = true

            $('#question-category').text("Next question is about #{question.category}")
            $('#question-author').text("by #{question.createdBy}")

            $('#question-pane').hide()
            $('#prepare-pane').fadeIn()


          socket.on "question.new", (question) ->
            return unless started

            $('#prepare-pane').hide()
            $('#question-pane').fadeIn()

            $('.correct').removeClass("correct")
            $('.wrong').removeClass("wrong")

            $('.selected').removeClass('selected')
            for answer in [1..4]
              $('#a' + answer).fadeIn('fast')

            $('#category').text("#{question.subCategory} / #{question.category}")
            $('#question').text("#{question.text}")

            keys = [1..4]
            keys.sort randOrd

            $('#a1').attr("data-answer", keys[0]).removeClass("selected").html(question['a' + keys[0]].replace(/\ /, '&nbsp;'))
            $('#a2').attr("data-answer", keys[1]).removeClass("selected").html(question['a' + keys[1]].replace(/\ /, '&nbsp;'))
            $('#a3').attr("data-answer", keys[2]).removeClass("selected").html(question['a' + keys[2]].replace(/\ /, '&nbsp;'))
            $('#a4').attr("data-answer", keys[3]).removeClass("selected").html(question['a' + keys[3]].replace(/\ /, '&nbsp;'))

          socket.on "answer.correct", (answer) ->
            console.log answer
            $('ul#answers li div[data-answer=' + answer + ']').addClass("selected correct")
            soundManager.play "correct"

          socket.on "answer.wrong", (answer) ->
            $('ul#answers li div[data-answer=' + answer + ']').addClass("selected wrong")
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

          socket.on "question.wait", (result) ->
            correct = result.correct

            if !started
              $('#countwait').html("Good luck!")
            $('#countdown').html("0")

            for answer in [1..4]
              $('ul#answers li div[data-answer=' + answer + ']').fadeOut() unless correct is "a#{answer}"

          socket.on "kicked", (msg) ->
            kicked = true
            $('#header-countwait').html("Disconnected")
            $('#countwait').html("You signed in with another client")
            $('#view-game, #view-prepare, #view-chat').hide()
            $('.display').removeClass('stripes')
            $('#view-wait').fadeIn()
            socket.disconnect()

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
      if $('#messages li').length > {duration: 30}
        $('#messages li:last-child').remove()
    , 1

  addAlert = (msg) ->
    listEntry "System", msg

  addBadge = (badge) ->
    badgeQueue.push badge
    processBadges() unless displayingBadge

  processBadges = () ->
    badge = badgeQueue.pop()

    if badge
      displayingBadge = true

      $('#badge-notify img').attr('src', "/img/#{badge.badge}.png")
      $('#badge-notify .name').html badge.name.substr(0, 8)
      $('#badge-notify .description').html badge.badge.replace(/likeasir/, 'like a sir').replace(/epicfail/, 'epic fail')

      $('#badge-notify').fadeIn(300).delay(3000).fadeOut 300, ->
        processBadges()
    else
      displayingBadge = false
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

  $('#view-game, #view-prepare, #header-countwait, #progress-starter, #progress-dna').hide()

  ### Intro ###

  $('.view-content .view-wait').show()

  $('#header-countwait').show()
  connect()
