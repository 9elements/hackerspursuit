fs = require("fs")
path = require("path")
sys = require("sys")
util = require("util")

Question = require('../classes/question')

randOrd = ->
  Math.round(Math.random())-0.5

Array::remove = (e) ->
  @[t..t] = [] if (t = @indexOf(e)) > -1

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

  removePlayersByHackerId: (hackerId) ->
    for player in @players
      try
        if player.user.hackerId == hackerId
          player.client.emit 'kicked', null
          player.client.disconnect()
      catch error

  
  joinPlayer: (player) ->
    @removePlayersByHackerId player.user.hackerId
    @players.push player

    profileImageUrl = @profileImageUrl player.user

    player.client.emit 'profile.info',
      id: player.user.id
      profileImage: profileImageUrl
      name: player.user.name

    @sendProfilingInfo(player)
    @broadcastScoreboard()

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
            
              for badge in player.checkBadges()
                # Broadcast badge and add it to persistent store
                global.store.badges.addBadge(player.user.hackerId, badge)
                @io.sockets.in("nerds").emit('badge.new', { name: player.user.name, badge: badge })

              @broadcastScoreboard()

              # Send profiling info
              @sendProfilingInfo(player)

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
      fileStats = fs.statSync(fileName)

      if fileStats.isFile()
        unless fileName.indexOf(".json") is -1
          try
            rawQuestion = JSON.parse(fs.readFileSync(fileName))

            @categoryCounts[rawQuestion.question.category] = 0 unless @categoryCounts[rawQuestion.question.category]?
            @categoryCounts[rawQuestion.question.category] += 1
            @categoryCounts['all'] += 1

            @questions.push ( new Question "question-#{rawQuestion.question.category}-#{name}",
              rawQuestion.question.nerdLevel,
              rawQuestion.question.text.replace(/ /, '&nbsp;'),
              rawQuestion.question.category.replace(/ /, '&nbsp;'),
              rawQuestion.question.sub_category,
              rawQuestion.question.a1.replace(/ /, '&nbsp;'),
              rawQuestion.question.a2.replace(/ /, '&nbsp;'),
              rawQuestion.question.a3.replace(/ /, '&nbsp;'),
              rawQuestion.question.a4.replace(/ /, '&nbsp;'),
              rawQuestion.question.right_answer,
              rawQuestion.question.created_at,
              rawQuestion.question.creator,
              rawQuestion.question.creator_twitter,
              rawQuestion.question.creator_github )
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
      scoreboard.push { name: player.user.name, points: player.points, wasRight: player.wasRight, wasFirst: player.wasFirst, userId: player.user.id }
    
    scoreboard.sort (a, b) ->
      return b.points - a.points
    
    @io.sockets.in("nerds").emit('scoreboard', scoreboard)

  getProfileData: (session, userId, callback) ->
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
        global.store.users.servicesForHackerId user.hackerId, defer err, connectedProvider
        global.store.scores.expById user.hackerId, defer err, exp

      # Score
      
      addScoreForCategory = (category, df) ->
        await global.store.scores.scoreByCategory category, user.hackerId, defer err, score
        categoryName = category.match(/(\w*)$/)[0].toUpperCase()
        categoryScore.push {
          name: categoryName
          score: score
        }
        df()

      await
        addScoreForCategory( category, defer() ) for category in categories
        global.store.scores.scoreById user.hackerId, defer err, realScore
        global.store.scores.overallById user.hackerId, defer err, overallScore

      # Badges

      addBadgeForUser = (badge, df) ->
        await global.store.badges.hasBadge user.hackerId, badge, defer err, hasBadge
        userBadges.push badge if hasBadge
        df()

      await
        addBadgeForUser( badge, defer() ) for badge in badges

      callback {
        profileName: user.name
        experience: if exp? then exp else 0
        realScore: if realScore? then realScore else 0
        overallScore: if overallScore? then overallScore else 0
        categoryScore: categoryScore
        categoryCounts: gameServer.categoryCounts
        badges: userBadges
        currentUser: (session.hackerId == user.hackerId)
        proposeTwitter: (connectedProvider.indexOf("twitter") == -1)
        proposeFacebook: (connectedProvider.indexOf("facebook") == -1)
        proposeGithub: (connectedProvider.indexOf("github") == -1)
        profileImage: @profileImageUrl user
      }

  profileImageUrl: (user) ->
    imageUrl = ""

    if user.id.indexOf("facebook") isnt -1
      imageUrl = "http://graph.facebook.com/#{user.username}/picture?type=normal"
    else if user.id.indexOf("twitter") isnt -1
      imageUrl = user.profile_image_url.replace(/_normal/, '_bigger')
    else if user.id.indexOf("github") isnt -1
      imageUrl = "http://www.gravatar.com/avatar/#{user.gravatar_id}"

    return imageUrl

  sendProfilingInfo: (player) =>
    await global.store.scores.overallById player.user.hackerId, defer err, overallScore
    overallScore = 0 unless overallScore?

    if overallScore < 30
      player.client.emit('progress.starter', parseInt(parseInt(overallScore) / 30 * 100))
    else
      categoryScore = []

      await global.store.scores.categoryKeys defer err, categories
      for category in categories
        await global.store.scores.scoreByCategory category, player.user.hackerId, defer err, score
        categoryName = category.match(/(\w*)$/)[0]
        util.puts categoryName

        categoryScore.push {
          name: categoryName
          progress: (parseInt(score / @categoryCounts[categoryName] * 100))
        }

      player.client.emit('progress.dna', categoryScore)

  rebuildScoreList: =>
    newHighscore = []
    c_scores = []
    c_users = []

    await global.store.scores.highScoreIds defer err, highest

    unless highest.length == 0
      count = highest.length - 1

      await
        for i in [0..count]
          global.store.users.findByHackerId highest[i], defer err_u, c_users[i]
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
        subCategory: @question.subCategory
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
