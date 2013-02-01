sys         = require 'sys'
express     = require 'express'
io          = require 'socket.io'
fs          = require 'fs'
util        = require 'util'
everyauth   = require 'everyauth'
http        = require 'http'
url         = require 'url'
request     = require 'request'
parseCookie = require('connect').utils.parseCookie
config      = global.config = require('./config')

### Classes ###
Player = require('./classes/player')
GameServer = require('./lib/gameserver')
Database = require('./lib/database')
configs = require('./lib/configs')

store = global.store = new Database(config.database.host, config.database.port, config.database.dbindex, config.database.auth)

HOST = config.server.host
PORT = config.server.port

process.on "uncaughtException", (err) ->
  console.log "UNCAUGHT EXCEPTION:"
  console.log err.stack

### Util ###

Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1

arrayContainerPlayer = (a, name) ->
  i = a.length
  while i--
    if a[i].name == name
      return true
  return false

### Everyauth ###

configs.everyauthConfig(everyauth)

### Server ###

app = express.createServer()
configs.expressConfig(express, config, app, everyauth)

### Handle Connections ###

scoreboard = []
acceptingAnswers = false

io = io.listen app

### Error Handling ###

logError = (error, socket) ->
  # sys.puts "Error: #{error}"
  throw error

### Start Server ###

gameserver = global.gameserver = new GameServer(io)
gameserver.startGame()

app.get '/', (req, res) ->
  res.render 'index', { host: config.server.host, port: config.server.port }

app.get '/highscore', (req, res) ->
  res.render 'highscore', { list: gameserver.highscore }

app.get '/profile/:id', (req, res) ->
  await gameserver.getProfileData req.session, req.params.id, defer data
  res.render 'profile', data

# Imagedata
app.get '/image', (req, res) ->
  request.get(req.param("url")).pipe(res)


# as soon as a user authenticates himself with a get request,
# make him join the "/nerds" room to join the game and receive
# question events
app.get '/user/auth-socket\.json', (req, res) ->
  res.writeHead 200, { "Content-Type": "application/json" }
  if req.loggedIn
    if req.query and req.query.hasOwnProperty("id")
      user = req.user
      client = gameserver.getClientById req.query.id
      if client
        # client authenticated, create new player
        player = new Player client, user
        gameserver.joinPlayer(player)

        client.authenticated = true

        client.join("nerds")
        res.end JSON.stringify({ success: true, error: null })
      else
        res.end JSON.stringify({ success: false, error: "id not found" })
    else
      res.end JSON.stringify({ success: false, error: "insufficient parameters given" })
  else
    res.end JSON.stringify({ success: false, error: "not logged in" })

app.listen(PORT)
sys.puts("Started server in #{app.settings.env} mode, listening to port #{PORT}.")