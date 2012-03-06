currentEnv = process.env.NODE_ENV or 'development'

exports.appName = "Hackerspursuit"

exports.env =
  production: false
  staging: false
  test: false
  development: false

exports.env[currentEnv] = true

exports.game =
  questionsPath: "./NerdPursuit/questions"
  prepareSeconds: 3
  countSeconds: 10
  pauseMilliseconds: 3000

if currentEnv == "development"
  exports.database =
    host: ""
    port: 5678
    dbindex: 1
    auth: ""

  exports.server =
    host: "local.hackerspursuit.com"
    port: 1234

  exports.twitter =
    consumerKey: ''
    consumerSecret: ''
    host: ''

if currentEnv == "production"
  exports.database =
    host: ""
    port: 5678
    dbindex: 1
    auth: ""

  exports.server =
    host: ""
    port: 1234

  exports.twitter =
    consumerKey: ''
    consumerSecret: ''
    host: ''