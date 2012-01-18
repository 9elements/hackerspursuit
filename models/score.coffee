module.exports = class
  constructor: (@client) ->
    null

  # Overall: Every right answer, only counter, will contain duplicates
  addOverall: (userId) ->
    currentScore = @client.zscore("score:overall", userId)
    if currentScore?
      newScore = currentScore + 1
      @client.zadd "score:overall", newScore, userId
    else
      @client.zadd "score:overall", 1, userId
  
  # Real: Unique right answers, answering the same question twice will not raise the count
  addReal: (userId, questionCategory, questionId) ->

    if @client.sadd "score:users:#{userId}:all", questionId

      # Cumulated count
      currentRealAll = @client.zscore("score:real:all", userId)
      if currentRealAll?
        newScore = currentRealAll + 1
        @client.zadd "score:real:all", newScore, userId
      else
        @client.zadd "score:real:all", 1, userId

      # Count by category
      currentRealCategory = @client.zscore("score:real:category:#{questionCategory}", userId)
      if currentRealCategory?
        newScore = currentRealCategory + 1
        @client.zadd "score:real:category:#{questionCategory}", newScore, userId
      else
        @client.zadd "score:real:category:#{questionCategory}", 1, userId

  highScoreIds: (callback) ->
    @client.zrevrange "score:real:all", 0, 10, (err, highest) ->
      callback err, highest

  highScoreById: (id, callback) ->
    @client.zscore "score:real:all", id, (err, score) ->
      callback err, score