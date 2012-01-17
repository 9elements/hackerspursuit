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
    
  checkAnswer: (n) ->
    if n == @answer
      @points += 1
      @wasRight = true
      return true
    else
      return false