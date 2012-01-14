(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(document).ready(function() {
    var addAlert, connect, sendAnswer, socket, startGame, started;
    soundManager.url = "/swfs/";
    soundManager.onready(function() {
      soundManager.createSound({
        id: 'wrong',
        url: ['/sounds/wrong.mp3', '/sounds/wrong.acc', '/sounds/wrong.ogg'],
        autoLoad: true
      });
      return soundManager.createSound({
        id: 'correct',
        url: ['/sounds/correct.mp3', '/sounds/correct.acc', '/sounds/correct.ogg'],
        autoLoad: true
      });
    });
    /* Communication */
    socket = null;
    started = false;
    startGame = function() {
      $('#view-login').hide();
      $('#view-wait').fadeIn();
      $(document).keydown(function(event) {
        var key;
        return key = event.keyCode ? event.keyCode : event.which;
      });
      $('#a1').click(function() {
        return sendAnswer(1);
      });
      $('#a2').click(function() {
        return sendAnswer(2);
      });
      $('#a3').click(function() {
        return sendAnswer(3);
      });
      return $('#a4').click(function() {
        return sendAnswer(4);
      });
    };
    connect = function() {
      socket = io.connect(host, {
        'port': parseInt(port)
      });
      return socket.on("connect", function() {
        var id;
        id = socket.socket.sessionid;
        return $.getJSON("/user/auth-socket.json?id=" + id, __bind(function(data) {
          startGame();
          if (data.success) {
            socket.on("question.new", function(question) {
              var answer;
              if (!started) {
                $('#view-wait').hide();
                $('#view-game').fadeIn();
                started = true;
              }
              $('.selected').removeClass('selected');
              for (answer = 1; answer <= 4; answer++) {
                $('#a' + answer).fadeIn('fast');
              }
              $('#question').text("" + question.category + ": " + question.text);
              $('#a1').removeClass("selected").text(question.a1);
              $('#a2').removeClass("selected").text(question.a2);
              $('#a3').removeClass("selected").text(question.a3);
              return $('#a4').removeClass("selected").text(question.a4);
            });
            socket.on("answer.correct", function(answer) {
              $('#' + answer).addClass("selected");
              return soundManager.play("correct");
            });
            socket.on("answer.wrong", function(answer) {
              $('#' + answer).addClass("selected");
              return soundManager.play("wrong");
            });
            socket.on("answer.twice", function() {
              return addAlert("ALREADY SELECTED AN ANSWER.");
            });
            socket.on("answer.over", function() {
              return addAlert("TIME IS OVER.");
            });
            socket.on("question.countdown", function(seconds) {
              if (started) {
                return $('#countdown').html(seconds);
              } else {
                return $('#countwait').html("JOINING IN " + seconds + " SECONDS...");
              }
            });
            socket.on("scoreboard", function(scoreboard) {
              var entry, listEntry, _i, _len, _results;
              $('#scoreboard li').remove();
              _results = [];
              for (_i = 0, _len = scoreboard.length; _i < _len; _i++) {
                entry = scoreboard[_i];
                listEntry = $('<li>').html("" + entry.name + ": " + entry.points);
                _results.push($('#scoreboard').append(listEntry));
              }
              return _results;
            });
            return socket.on("question.wait", function(result) {
              var answer, correct, _results;
              correct = result.correct;
              if (!started) {
                $('#countwait').html("GOOD LUCK!");
              }
              $('#countdown').html("OVER");
              _results = [];
              for (answer = 1; answer <= 4; answer++) {
                _results.push(correct !== ("a" + answer) ? $('#a' + answer).fadeOut() : void 0);
              }
              return _results;
            });
          } else {
            return alert("Could not authenticate: " + data.error);
          }
        }, this));
      });
    };
    sendAnswer = function(n) {
      if (socket == null) {
        return;
      }
      return socket.emit('answer.set', {
        answer: n
      });
    };
    /* Alerts and Notices */
    addAlert = function(msg) {
      var alertEntry;
      alertEntry = $('<li>').html("Alert: " + msg).fadeIn().delay(3000).fadeOut();
      return $('#alert').append(alertEntry.toUpperCase());
    };
    /* Views */
    $('.view-content').hide();
    return connect();
  });
}).call(this);
