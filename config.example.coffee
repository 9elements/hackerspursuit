currentEnv = process.env.NODE_ENV or 'development'

exports.appName = "Hackerspursuit"

exports.env =
  production: false
  staging: false
  test: false
  development: false

exports.env[currentEnv] = true

exports.server =
  host: "local.hackerspursuit.com"
  port: 3030

exports.database =
  host : "stage.hackerspursuit.com"
  port : 3030
  dbindex : 1
  auth : ""

exports.game =
  questionsPath: "../HPQuestions/questions"
  countSeconds: 10
  pauseMilliseconds: 3000
  prepareSeconds: 3

if currentEnv == "development"
  exports.twitter =
    consumerKey: ''
    consumerSecret: ''
    host: 'http://local.hackerspursuit.com:3030'

  exports.facebook =
    appId: ''
    appSecret: ''
    host: 'http://local.hackerspursuit.com:3030'

if currentEnv == "production"
  exports.twitter =
    consumerKey: ''
    consumerSecret: ''
    host: 'http://www.hackerspursuit.com'

  exports.facebook =
    appId: ''
    appSecret: ''
    host: 'http://www.hackerspursuit.com'
