module.exports = class
  constructor: (@client) ->
    null
  
  findOrCreate: (authMethod, userData, callback) ->
    id = "#{authMethod}-#{userData.id}"
    @client.get "user:#{id}", (err, user) =>
      unless user?
        # create new user
        userData.id = id
        @client.set "user:#{id}", JSON.stringify(userData)
        callback userData
      else
        console.log "user is given"
        callback JSON.parse(user)
  
  findById: (id, callback) ->
    @client.get "user:#{id}", (err, user) =>
      unless user?
        callback null, null
      else
        callback null, JSON.parse(user)