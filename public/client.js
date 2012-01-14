(function() {
  $(document).ready(function() {
    var addAlert, connect, loggedIn, sendAnswer, socket, socket_host, socket_port, startGame, started, userid;
    socket_host = $('#server-host').text();
    socket_port = $('#server-port').text();
    /* Communication */
    socket = null;
    loggedIn = false;
    started = false;
    connect = function() {
      socket = io.connect(socket_host, {
        'port': parseInt(socket_port)
      });
      socket.on("login.invalid", function() {
        console.log("Login invalid");
        $('#view-login').fadeIn();
        return addAlert("Username invalid.");
      });
      socket.on("login.success", function(player) {
        console.log("Login done");
        loggedIn = true;
        return startGame();
      });
      socket.on("answer.locked", function(answer) {
        return $('#' + answer).addClass("selected");
      });
      socket.on("answer.twice", function() {
        return addAlert("Already selected an answer.");
      });
      socket.on("answer.over", function() {
        return addAlert("The time is over.");
      });
      socket.on("question.new", function(question) {
        var answer;
        if (!loggedIn) {
          return;
        }
        if (!started) {
          $('#view-wait').hide();
          $('#view-game').fadeIn();
          started = true;
        }
        $('.selected').removeClass('selected');
        for (answer = 1; answer <= 4; answer++) {
          $('#a' + answer).fadeIn('fast');
        }
        $('#question').html("" + question.category + ": " + question.text);
        $('#a1').html(question.a1);
        $('#a2').html(question.a2);
        $('#a3').html(question.a3);
        return $('#a4').html(question.a4);
      });
      socket.on("question.countdown", function(seconds) {
        if (started) {
          return $('#countdown').html(seconds);
        } else {
          return $('#countwait').html("Joining in " + seconds + " seconds...");
        }
      });
      return socket.on("question.wait", function(result) {
        var answer, correct, entry, listEntry, scoreboard, _i, _len, _results;
        scoreboard = result.scoreboard;
        correct = result.correct;
        if (!started) {
          $('#countwait').html("Good luck!");
        }
        $('#countdown').html('Over');
        $('#scoreboard li').remove();
        for (_i = 0, _len = scoreboard.length; _i < _len; _i++) {
          entry = scoreboard[_i];
          listEntry = $('<li>').html("" + entry.name + ": " + entry.points);
          $('#scoreboard').append(listEntry);
        }
        _results = [];
        for (answer = 1; answer <= 4; answer++) {
          _results.push(correct !== ("a" + answer) ? $('#a' + answer).fadeOut() : void 0);
        }
        return _results;
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
    /* Alerts and Notices */
    addAlert = function(msg) {
      var alertEntry;
      alertEntry = $('<li>').html("Alert: " + msg).fadeIn().delay(3000).fadeOut();
      return $('#alert').append(alertEntry);
    };
    /* Views */
    $('.view-content').hide();
    userid = $('#userid').text();
    if (userid) {
      if (socket == null) {
        connect();
      }
      return socket.emit('login.request', {
        userid: userid
      });
    } else {
      return $('#view-login').fadeIn();
    }
  });
}).call(this);
