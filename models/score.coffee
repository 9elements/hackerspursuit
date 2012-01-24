module.exports = class
  constructor: (@client) ->
    null

  # Overall: Every right answer, only counter, will contain duplicates
  addOverall: (userId) ->
    @client.zscore "score:overall", userId, (err, currentScore) =>
      if currentScore?
        newScore = parseInt(currentScore) + 1
        @client.zadd "score:overall", newScore, userId
      else
        @client.zadd "score:overall", 1, userId
  
  # Real: Unique right answers, answering the same question twice will not raise the count
  addReal: (userId, questionCategory, questionId) ->

    @client.sadd "score:users:#{userId}:all", questionId, (err, result) =>

      # Update real counts only if this question wasn't answered right before
      if result > 0
        
        # Cumulated count
        @client.zscore "score:real:all", userId, (err, currentRealAll) =>
          if currentRealAll?
            newScore = parseInt(currentRealAll) + 1
            @client.zadd "score:real:all", newScore, userId
          else
            @client.zadd "score:real:all", 1, userId

        # Count by category
        @client.zscore "score:real:category:#{questionCategory}", userId, (err, currentRealCategory) =>
          if currentRealCategory?
            newScore = parseInt(currentRealCategory) + 1
            @client.zadd "score:real:category:#{questionCategory}", newScore, userId
          else
            @client.zadd "score:real:category:#{questionCategory}", 1, userId

  highScoreIds: (callback) ->
    @client.zrevrange "score:real:all", 0, 10, (err, highest) ->
      callback err, highest

  scoreById: (id, callback) ->
    @client.zscore "score:real:all", id, (err, score) ->
      callback err, score

  overallById: (id, callback) ->
    @client.zscore "score:overall", id, (err, score) ->
      callback err, score

  categoryKeys: (callback) ->
    @client.keys "score:real:category:*", (err, keys) ->
      callback err, keys

  scoreByCategory: (category, id, callback) ->
    @client.zscore category, id, (err, score) ->
      callback err, score