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

  checkStats: ->
    newBadges = []
    newBadges.push 'rampage' if @firstInARow == 3
    newBadges.push 'epic' if @rightInARow == 10
    newBadges.push 'godmode' if @rightInARow == 10

    newBadges.push 'pawned' if @highThree == 1
    newBadges.push 'monsterpawned' if @highThree == 3

    newBadges.push 'failed' if @wrongInARow == 5
    newBadges.push 'epicfail' if @wrongInARow == 10

    # TODO: TRUE CODER

    return newBadges
    
  checkAnswer: (question, first, competitors) ->
    if question.correct == @answer
      @points += 1
      @wasRight = true

      # Save data to persistent store
      global.store.scores.addOverall @user.hackerId
      global.store.scores.addReal @user.hackerId, question.category, question.id

      # Stats
      @.refreshStats(question, first, true, competitors)

      return true
    else
      
      @.refreshStats(question, false, false, competitors)
      return false