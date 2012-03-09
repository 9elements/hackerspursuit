module.exports = class
  constructor: (@client) ->
    null
  
  findOrCreate: (authMethod, userData, session, callback) ->
    providerId = "provider:#{authMethod}-#{userData.id}"

    @client.get providerId, (err, user) =>
      if user?
        # User logged in with this account before

        if session.hackerId?
          # User already logged in with an account, check if merge is necessary

          if user.hackerId == session.hackerId
            # This account belongs to the logged in account (perheaps the same)
            callback JSON.parse(user)

          else
            # This account is an additional account for the logged in account
            # TODO: Merge old data into new record
            # TODO: Remove providerId from previous user
            userData.hackerId = session.hackerId
            userData.id = providerId
            @client.set providerId, JSON.stringify(userData)
            @client.sadd "user:#{session.hackerId}", providerId
            callback userData

        else
          # User currently logged out, use stored data, and set hackerId
          session.hackerId = userData.hackerId
          callback userData

      else
        # New account, create and set hackerId
        session.hackerId = "#{session.id}" unless session.hackerId?
        userData.hackerId = session.hackerId
        userData.id = providerId
        @client.set providerId, JSON.stringify(userData)
        @client.sadd "user:#{session.hackerId}", providerId
        callback userData

  
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