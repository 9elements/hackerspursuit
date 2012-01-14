fs = require("fs")
path = require("path")
sys = require("sys")

Question = require('../classes/question')

module.exports = class
  constructor: (@io) ->
    @questions = []
    @players = []
    @clients = {}
  
  getClientById: (id) ->
    if @clients.hasOwnProperty(id)
      return @clients[id]
    else
      return null
  
  joinPlayer: (player) =>
    @players.push player

    player.client.on 'answer.set', (msg) =>
      return unless player.client.authenticated
      try 
        if not @acceptingAnswers
          player.client.emit 'answer.over', null
        else
          n = parseInt(msg.answer)
          if n > 0 and n < 5
            if player.setAnswer "a#{n}"
              if player.checkAnswer @question.correct
                player.client.emit 'answer.correct', "a#{n}"
              else
                player.client.emit 'answer.wrong', "a#{n}"
              @broadcastScoreboard()
            else
              player.client.emit 'answer.twice', null

  loadQuestions: (path) ->
    files = fs.readdirSync(path)
    for name in files
      fileName = "#{path}/#{name}"
      fileStats = fs.statSync(fileName)
      if fileStats.isFile()
        unless fileName.indexOf(".json") is -1
          try
            rawQuestion = JSON.parse(fs.readFileSync(fileName))
            @questions.push ( new Question rawQuestion.question.nerdLevel,
              rawQuestion.question.text,
              rawQuestion.question.category,
              rawQuestion.question.a1,
              rawQuestion.question.a2,
              rawQuestion.question.a3,
              rawQuestion.question.a4,
              rawQuestion.question.right_answer,
              rawQuestion.question.created_at,
              rawQuestion.question.created_by )
              
          catch error
            sys.puts "Warning: Could not parse question #{fileName}"
      else
        @loadQuestions fileName
  
  startGame: ->
    @loadQuestions global.config.game.questionsPath
    
    @question        = null
    @leftSeconds     = 0
    @currentQuestion = 0

    @io.sockets.on "connection", (client) =>
      # as soon as a client connects, let him authorize via a json url

      @clients[client.id] = client

      client.on "disconnect", =>
        i = 0
        for player in @players
          if player.client is client
            @players.splice i, 1
        i++

        if @clients.hasOwnProperty client.id
          delete @clients[client.id]
    
    @initCycle()
    
  broadcastScoreboard: =>
    scoreboard = []
    for player in @players
      scoreboard.push { name: player.user.name, points: player.points, wasRight: player.wasRight }
    
    scoreboard.sort (a, b) ->
      return b.points - a.points
    
    @io.sockets.in("nerds").emit('scoreboard', scoreboard)

  endCycle: =>
    @acceptingAnswers = false
      
    @io.sockets.in("nerds").emit('question.wait', {
      correct: @question.correct
      })
    
    @broadcastScoreboard()
    
    setTimeout @initCycle, global.config.game.pauseMilliseconds
    
  countDown: (seconds) =>
    @leftSeconds -= 1
    if @leftSeconds > 0
      @io.sockets.in("nerds").emit('question.countdown', @leftSeconds)
      setTimeout @countDown, 1000
    else
      @endCycle()

  initCycle: =>
    for player in @players
      player.resetAnswer()
      
    @acceptingAnswers = true
    if @currentQuestion == @questions.length
      @currentQuestion = 0
      @questions.shuffle()

    @question = @questions[@currentQuestion]

    @io.sockets.in("nerds").emit('question.new', {
      nerdLevel: @question.nerdLevel,
      text: @question.text,
      category: @question.category,
      a1: @question.a1,
      a2: @question.a2,
      a3: @question.a3,
      a4: @question.a4,
      createdAt: @question.createdAt,
      createdBy: @question.createdBy,
      countdown: global.config.game.countSeconds
    })
    
    @currentQuestion += 1
    @leftSeconds = global.config.game.countSeconds
    @countDown()