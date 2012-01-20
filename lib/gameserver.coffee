fs = require("fs")
path = require("path")
sys = require("sys")
util = require("util")

Question = require('../classes/question')

randOrd = ->
  Math.round(Math.random())-0.5

module.exports = class
  constructor: (@io) ->
    @questions = []
    @players = []
    @clients = {}
    @highscore = []
  
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
              if player.checkAnswer @question
                player.client.emit 'answer.correct', n
              else
                player.client.emit 'answer.wrong', n
              @broadcastScoreboard()
            else
              player.client.emit 'answer.twice', null

    player.client.on 'chat.msg', (msg) =>
      return unless player.client.authenticated
      @io.sockets.in("nerds").emit('chat.msg', {name: player.user.name, msg: msg.content})    

  loadQuestions: (path) ->
    files = fs.readdirSync(path)
    for name in files
      fileName = "#{path}/#{name}"

      # Use own catname and id
      catName = path.match(/(\w*)$/)[0]
      questionId = "question-#{catName}-#{name}"

      fileStats = fs.statSync(fileName)
      if fileStats.isFile()
        unless fileName.indexOf(".json") is -1
          try
            rawQuestion = JSON.parse(fs.readFileSync(fileName))
            @questions.push ( new Question questionId,
              rawQuestion.question.nerdLevel,
              rawQuestion.question.text,
              catName,
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
    @loadQuestions( global.config.game.questionsPath )
    @questions.sort randOrd
    
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
    @rebuildScoreList()

    setTimeout @initCycle, global.config.game.pauseMilliseconds
    
  countDown: (seconds) =>
    @leftSeconds -= 1
    if @leftSeconds > 0
      @io.sockets.in("nerds").emit('question.countdown', @leftSeconds)
      setTimeout @countDown, 1000
    else
      @endCycle()

  renderProfile: (req, res) ->
    userId = req.params.id

    global.store.users.findById userId, (err, user) ->
      unless user?
        res.render 'profile', { error: "Profile not found" }
      else
        finishedCount = 0
        realScore = 0
        overallScore = 0
        categoryScore = []

        checkFinish = =>
          finishedCount -= 1
          if finishedCount == 0
            res.render 'profile', {
              profileName: user.name
              realScore: realScore
              overallScore: overallScore
              categoryScore: categoryScore
            }

        addScoreForCategory = (category) ->
          global.store.scores.scoreByCategory category, userId, (err, score) ->
            categoryName = category.match(/(\w*)$/)[0].toUpperCase()
            categoryScore.push {
              name: categoryName
              score: score
            }
            checkFinish()

        global.store.scores.categoryKeys (err, categories) ->
          finishedCount = categories.length + 2
          addScoreForCategory category for category in categories
          
          global.store.scores.scoreById userId, (err, score) ->
            realScore = score
            checkFinish()

          global.store.scores.overallById userId, (err, score) ->
            overallScore = score
            checkFinish()



  rebuildScoreList: =>
    finishedCount = 0
    newHighscore = []

    checkFinish = =>
      finishedCount -= 1
      if finishedCount == 0
        @highscore = newHighscore

    addEntryFor = (list_entry, i) =>
      global.store.scores.scoreById list_entry, (err, score) ->
        newHighscore[i] = { score: score }
        global.store.users.findById list_entry, (err, user) ->
          newHighscore[i].userName = user.name
          newHighscore[i].userId = user.id
          checkFinish()

    global.store.scores.highScoreIds (err, highest) ->
      finishedCount = highest.length
      i = 0
      for list_entry in highest
        addEntryFor(list_entry, i)
        i += 1


  initCycle: =>
    for player in @players
      player.resetAnswer()
      
    @acceptingAnswers = true
    if @currentQuestion == @questions.length
      @currentQuestion = 0
      @questions.sort randOrd

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