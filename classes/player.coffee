module.exports = class
  constructor: (@client, @user) ->
    @resetAnswer()
    @points = 0

    # Init stats
    @firstInARow = 0
    @rightInARow = 0
    @wrongInARow = 0
    @highThree = 0
  
  setAnswer: (n) ->
    return false unless @answer == 'a0'
    @answer = n
    return true
    
  resetAnswer: ->
    @answer = 'a0'
    @wasRight = false
    @wasFirst = false

  refreshStats: (question, first, right, competitors) ->

    if competitors > 1
      if right
        @rightInARow += 1
        @wrongInARow = 0
        @firstInARow += 1 if first
      else
        @wrongInARow += 1
        @rightInARow = 0
        @firstInARow = 0

    if parseInt(question.nerdLevel) > 3 and competitors > 10
      if right and first
        @highThree += 1 
      else if not right
        @highThree = 0

  checkBadges: ->
    newBadges = []
    newBadges.push 'rampage' if @firstInARow == 3
    newBadges.push 'epic' if @rightInARow == 10
    newBadges.push 'likeasir' if @rightInARow == 20

    newBadges.push 'pawned' if @highThree == 1
    newBadges.push 'monsterpawned' if @highThree == 3

    newBadges.push 'fail' if @wrongInARow == 5
    newBadges.push 'epicfail' if @wrongInARow == 10

    # TODO: TRUE CODER

    return newBadges
    
  checkAnswer: (question, first, competitors) ->
    if question.correct == @answer
      @wasRight = true
      @wasFirst = first

      # Category score and exp
      global.store.scores.addOverall @user.hackerId
      global.store.scores.addReal @user.hackerId, question.category, question.id

      if first and competitors > 15
        @points += 3
        global.store.scores.addExp @user.hackerId, 3
      else if first and competitors > 1
        @points += 2
        global.store.scores.addExp @user.hackerId, 2
      else
        @points += 1
        global.store.scores.addExp @user.hackerId, 1

      # Stats
      @.refreshStats(question, first, true, competitors)

      return true
    else
      
      # Exp
      if @points > 0
        @points -= 1
        global.store.scores.addExp @user.hackerId, -1

      # Stats
      @.refreshStats(question, false, false, competitors)
      return false
