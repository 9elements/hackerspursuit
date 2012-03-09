module.exports = 
  expressConfig: (express, config, app, everyauth) ->
    RedisStore = require("connect-redis")(express)
    redisStore = new RedisStore
      maxAge: 60 * 60 * 24 * 30
      host: config.database.host
      port: config.database.port
      db: config.database.dbindex
      pass: config.database.auth
      no_ready_check: true

    app.configure ->
      app.set 'views', __dirname + '/../views'
      app.set 'view engine', 'jade'
      app.use express.bodyParser()
      app.use express.cookieParser()
      app.use express.session { store: redisStore, secret: "asdfhgk37r9r809p23h2kg"}
      app.use express.methodOverride()

      app.use require("stylus").middleware
        src: __dirname + '/../src/stylus/'
        dest: __dirname + '/../public'
        compress: true

      app.use express.compiler( src: "#{__dirname}/../src/coffee/", dest: "#{__dirname}/../public", enable: ['coffeescript'] )
      app.use express.static(__dirname + '/../public')
      app.use express.logger()
      app.use express.errorHandler()
      app.use everyauth.middleware()  
      app.use app.router

    everyauth.helpExpress app

    app.configure 'development', ->
      app.use express.errorHandler({
        dumpExceptions: true,
        showStack: true
      })
      
    app.configure 'production', ->
      app.use express.errorHandler()
  
  everyauthConfig: (everyauth) ->

    everyauth.twitter
    .consumerKey(config.twitter.consumerKey)
    .consumerSecret(config.twitter.consumerSecret)
    .myHostname(config.twitter.host)
    .findOrCreateUser (session, accessToken, accessTokenSecret, twitterUserMetadata) ->
      promise = @.Promise()
      global.store.users.findOrCreate "twitter", twitterUserMetadata, session, (user) ->
        promise.fulfill(user)
      return promise
    .redirectPath('/')

    everyauth.facebook
      .appId(config.facebook.appId)
      .appSecret(config.facebook.appSecret)
      .myHostname(config.facebook.host)
      .handleAuthCallbackError (req, res) ->
        sys.util "Facebook Auth Callback Error. Oh noes!"
      .findOrCreateUser (session, accessToken, accessTokExtra, fbUserMetadata) ->
        promise = @.Promise()
        global.store.users.findOrCreate "facebook", fbUserMetadata, session, (user) ->
          promise.fulfill(user)
        return promise
      .redirectPath('/')
      
    everyauth.everymodule.findUserById (userId, callback) ->
      global.store.users.findById userId, (err, user) ->
        callback err, user