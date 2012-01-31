module.exports = class
  constructor: (@client, @user) ->
    @resetAnswer()
    @points = 0
    @.resetStats()
  
  setAnswer: (n) ->
    return false unless @answer == 'a0'
    @answer = n
    return true
    
  resetAnswer: ->
    @answer = 'a0'
    @wasRight = false

  resetStats: ->
    @firstInARow = 0
    @rightInARow = 0

  addStats: (first) ->
    @rightInARow += 1
    @firstInARow += 1 if first

  checkStats: ->
    newBadges = []
    newBadges.push 'rampage' if @firstInARow == 3
    newBadges.push 'epic' if @rightInARow == 10

    return newBadges
    
  checkAnswer: (question, first) ->
    if question.correct == @answer
      @points += 1
      @wasRight = true

      # Save data to persistent store
      global.store.scores.addOverall @user.id
      global.store.scores.addReal @user.id, question.category, question.id

      # Stats
      @.addStats(first)

      return true
    else
      @.resetStats()
      return false