module.exports = class
  constructor: (@client) ->
    null
  
  findOrCreate: (authMethod, userData, session, callback) ->
    providerId = "provider:#{authMethod}-#{userData.id}"

    @client.get providerId, (err, user) =>
      if user?
        # User logged in with this account before
        user = JSON.parse(user)

        if session.hackerId?
          # User already logged in with an account, check if merge is necessary

          if user.hackerId == session.hackerId
            # This account belongs to the logged in account (perheaps the same)
            callback user

          else
            # This account is an additional account for the logged in account
            @client.del "user:#{user.hackerId}"
            userData.hackerId = session.hackerId
            userData.id = providerId
            @client.set providerId, JSON.stringify(userData)
            @client.sadd "user:#{session.hackerId}", providerId

            # Merge old data into new record
            @.merge(user.hackerId, session.hackerId)

            callback userData

        else
          # User currently logged out, use stored data, and set hackerId
          session.hackerId = user.hackerId
          callback user

      else
        # New account, create and set hackerId
        session.hackerId = "#{session.id}" unless session.hackerId?
        userData.hackerId = session.hackerId
        userData.id = providerId
        @client.set providerId, JSON.stringify(userData)
        @client.sadd "user:#{session.hackerId}", providerId
        callback userData


  merge: (oldId, newId) ->

    # Badges

    @client.keys "badge:*", (err, keys) =>
      for key in keys
        @client.srem key, oldId, (err, result) =>
          if result > 0
            # User had this badge
            @client.sadd key, newId

    # Category score

    @client.zscore "score:overall", oldId, (err, oldScore) =>
      @client.zincrby "score:overall", oldScore, newId if oldScore?

    @client.smembers "score:users:#{oldId}:all", (err, questionIds) =>
      for questionId in questionIds
        questionCategory = questionId.match(/question-(\w*)/)[1]

        @client.sadd "score:users:#{newId}:all", questionId, (err, result) =>

          # Update real counts only if this question wasn't answered right before
          if result > 0
            @client.zincrby "score:real:all", 1, newId
            @client.zincrby "score:real:category:#{questionCategory}", 1, newId

    # Experience

    @client.zscore "experience:all", oldId, (err, oldExperience) =>
      @client.zincrby "experience:all", oldExperience, newId if oldExperience?

    # Delete old user records

    @client.del "score:users:#{oldId}:all"
    @client.zrem "experience:all", oldId
    @client.zrem "score:overall", oldId
    @client.zrem "score:real:all", oldId
    @client.keys "score:real:category:*", (err, keys) =>
      for key in keys
        @client.zrem key, oldId
  
  findById: (id, callback) ->
    @client.get id, (err, user) =>
      unless user?
        callback err, null
      else
        callback null, JSON.parse(user)

  findByHackerId: (id, callback) ->
    @client.smembers "user:#{id}", (err, provider) =>
      unless provider?
        callback err, null
      else
        @.findById provider[0], callback

  servicesForHackerId: (id, callback) ->
    @client.smembers "user:#{id}", (err, provider) =>
      unless provider?
        callback err, null
      else
        callback null, provider.join("")
