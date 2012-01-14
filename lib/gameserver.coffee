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
    console.log "getClientById"
    if @clients.hasOwnProperty(id)
      return @clients[id]
    else
      return null
  
  joinPlayer: (player) ->
    console.log "joinPlayer"
    @players.push player

  loadQuestions: (path) ->
    console.log "loadQuestions"
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
    console.log "startGame"
    @loadQuestions global.config.game.questionsPath
    
    @question        = null
    @leftSeconds     = 0
    @currentQuestion = 0

    @io.sockets.on "connection", (client) =>
      # as soon as a client connects, let him authorize via a json url

      @clients[client.id] = client

      client.on 'answer.set', (msg) =>
        return unless client.authenticated
        try 
          if not @acceptingAnswers
            client.emit 'answer.over', null
          else
            n = parseInt(msg.answer)
            if n > 0 and n < 5
              if player.setAnswer "a#{n}"
                client.emit 'answer.locked', "a#{n}"
              else
                client.emit 'answer.twice', null
    
    @initCycle()
    
  endCycle: =>
    console.log "endCycle"
    @acceptingAnswers = false
    scoreboard = []
    
    for player in @players
      player.checkAnswer(@question.correct)
      scoreboard.push { name: player.user.name, points: player.points, wasRight: player.wasRight }
    
    scoreboard.sort (a, b) ->
      return b.points - a.points
      
    @io.sockets.in("nerds").emit('question.wait', {
      scoreboard: scoreboard,
      correct: @question.correct
      })
    
    setTimeout @initCycle, global.config.game.pauseMilliseconds
    
  countDown: (seconds) =>
    console.log "countDown"
    @leftSeconds -= 1
    if @leftSeconds > 0
      @io.sockets.in("nerds").emit('question.countdown', @leftSeconds)
      setTimeout @countDown, 1000
    else
      @endCycle()
        
  initCycle: =>
    console.log "initCycle"
    console.log @players
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