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
    @categoryCounts = {all: 0}
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

    player.client.emit 'profile.info',
      id: player.user.id
      profileImage: player.user.profile_image_url.replace(/_normal/, '_bigger')
      name: player.user.name

    player.client.on 'answer.set', (msg) =>
      return unless player.client.authenticated
      try 
        if not @acceptingAnswers
          player.client.emit 'answer.over', null
        else
          n = parseInt(msg.answer)
          if n > 0 and n < 5
            if player.setAnswer "a#{n}"
              if player.checkAnswer @question, @firstRight, @players.length
                @firstRight = false
                player.client.emit 'answer.correct', n
              else
                player.client.emit 'answer.wrong', n
            
              for badge in player.checkStats()
                # Broadcast badge and add it to persistent store
                global.store.badges.addBadge(player.user.id, badge)
                @io.sockets.in("nerds").emit('badge.new', { name: player.user.name, badge: badge })

              @broadcastScoreboard()
            else
              player.client.emit 'answer.twice', null

    player.client.on 'chat.msg', (msg) =>
      return unless player.client.authenticated
      chatMsg = msg.content.replace(/&/g, '').replace(/</g, '').replace(/"/g, '&quot;')
      return unless chatMsg.length > 0
      @io.sockets.in("nerds").emit('chat.msg', {name: player.user.name, msg: chatMsg})    

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
            @categoryCounts[catName] = 0 unless @categoryCounts[catName]?
            @categoryCounts[catName] += 1
            @categoryCounts['all'] += 1
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
    @loadQuestions( global.config.game.questionsPath)
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
      scoreboard.push { name: player.user.name, points: player.points, wasRight: player.wasRight, userId: player.user.id }
    
    scoreboard.sort (a, b) ->
      return b.points - a.points
    
    @io.sockets.in("nerds").emit('scoreboard', scoreboard)

  getProfileData: (userId, callback) ->
    gameServer = @

    await
      global.store.users.findById userId, defer err, user

    unless user?
      callback { error: "Profile not found" }
    else
      realScore = 0
      overallScore = 0
      categoryScore = []
      userBadges = []
      
      await
        global.store.scores.categoryKeys defer err, categories
        global.store.badges.badgeKeys defer err, badges

      # Score
      
      addScoreForCategory = (category, df) ->
        await global.store.scores.scoreByCategory category, userId, defer err, score
        categoryName = category.match(/(\w*)$/)[0].toUpperCase()
        categoryScore.push {
          name: categoryName
          score: score
        }
        df()

      await
        addScoreForCategory( category, defer() ) for category in categories
        global.store.scores.scoreById userId, defer err, realScore
        global.store.scores.overallById userId, defer err, overallScore

      # Badges

      addBadgeForUser = (badge, df) ->
        await global.store.badges.hasBadge userId, badge, defer err, hasBadge
        userBadges.push badge if hasBadge
        df()

      await
        addBadgeForUser( badge, defer() ) for badge in badges

      callback {
        profileName: user.name
        realScore: realScore
        overallScore: overallScore
        categoryScore: categoryScore
        categoryCounts: gameServer.categoryCounts
        badges: userBadges
      }

  rebuildScoreList: =>
    newHighscore = []
    c_scores = []
    c_users = []

    await global.store.scores.highScoreIds defer err, highest
    count = highest.length - 1

    await
      for i in [0..count]
        global.store.users.findById highest[i], defer err_u, c_users[i]
        global.store.scores.scoreById highest[i], defer err_s, c_scores[i]

    for i in  [0..count]
      newHighscore[i] = { 
        score: c_scores[i]
        userName: c_users[i].name
        userId: c_users[i].id 
      }

    @highscore = newHighscore


  initCycle: =>
    for player in @players
      player.resetAnswer()
      
    if @currentQuestion == @questions.length
      @currentQuestion = 0
      @questions.sort randOrd

    @question = @questions[@currentQuestion]
    @firstRight = true

    @io.sockets.in("nerds").emit('question.prepare', {
      nerdLevel: @question.nerdLevel,
      text: @question.text,
      category: @question.category,
      createdAt: @question.createdAt,
      createdBy: @question.createdBy,
      countdown: global.config.game.countSeconds
    })

    setTimeout =>
      @acceptingAnswers = true

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
    , global.config.game.prepareSeconds * 1000

  countDown: (seconds) =>
    @leftSeconds -= 1
    if @leftSeconds > 0
      @io.sockets.in("nerds").emit('question.countdown', @leftSeconds)
      setTimeout @countDown, 1000
    else
      @endCycle()

  endCycle: =>
    @acceptingAnswers = false
      
    @io.sockets.in("nerds").emit('question.wait', {
      correct: @question.correct
      })
    
    @broadcastScoreboard()
    @rebuildScoreList()

    setTimeout @initCycle, global.config.game.pauseMilliseconds