module.exports = class
  constructor: (@client, @user) ->
    @resetAnswer()
    @points = 0
  
  setAnswer: (n) ->
    return false unless @answer == 'a0'
    @answer = n
    return true
    
  resetAnswer: ->
    @answer = 'a0'
    @wasRight = false
    
  checkAnswer: (question) ->
    if question.correct == @answer
      @points += 1
      @wasRight = true

      # Save data to persistent store
      global.store.scores.addOverall @user.id
      global.store.scores.addReal @user.id, question.category, question.id

      return true
    else
      return false