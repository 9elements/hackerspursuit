randomString = ->
  chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz"
  randomstring = ''
  for i in [0..32]
    rnum = Math.floor(Math.random() * chars.length)
    randomstring = randomstring + "#{chars.substring(rnum,rnum+1)}"
  
  return randomstring

module.exports = class
  constructor: (@client, @user) ->
    @id = randomString()
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