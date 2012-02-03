module.exports = class
  constructor: (@client) ->
    null

  addBadge: (userId, badge) ->
    @client.sadd "badge:#{badge}", userId

  badgeKeys: (callback) ->
    @client.keys "badge:*", (err, keys) ->
      callback err, keys

  hasBadge: (userId, badge, callback) ->
    @client.sismember "#{badge}", userId, (err, result) ->
      if result > 0 then callback( err, true )  else callback( err, false ) 