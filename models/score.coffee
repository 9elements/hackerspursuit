module.exports = class
  constructor: (@client) ->
    null


  ### Experience Stuff ###

  addExp: (userId, exp, callback) ->
    @client.zincrby "experience:all", exp, userId

  expById: (userId, callback) ->
    @client.zscore "experience:all", userId, (err, exp) =>
      callback err, exp

  ### Category Stuff ###

  # Overall: Every right answer, only counter, will contain duplicates
  addOverall: (userId) ->
    @client.zincrby "score:overall", 1, userId
  
  # Real: Unique right answers, answering the same question twice will not raise the count
  addReal: (userId, questionCategory, questionId) ->

    questionCategory = questionCategory.replace(/[^a-zA-Z0-9]+/g,'')

    @client.sadd "score:users:#{userId}:all", questionId, (err, result) =>

      # Update real counts only if this question wasn't answered right before
      if result > 0
        @client.zincrby "score:real:all", 1, userId
        @client.zincrby "score:real:category:#{questionCategory}", 1, userId

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