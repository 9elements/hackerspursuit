(function() {
  var randOrd;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  randOrd = function() {
    return Math.round(Math.random()) - 0.5;
  };
  $(document).ready(function() {
    var addAlert, connect, intro, listEntry, loaded, sendAnswer, socket, startGame, started;
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
    loaded = false;
    startGame = function() {
      $('#view-login').hide();
      return $('#view-wait').fadeIn();
    };
    connect = function() {
      socket = io.connect(host, {
        'port': parseInt(port)
      });
      socket.on("profile.info", function(profile) {
        return $.getImageData({
          url: profile.profileImage,
          success: function(image) {
            var average, canvas, canvas_el, h, i, image_data, j, size, w, _ref, _ref2, _ref3, _ref4, _step, _step2;
            $('#canvas-container').empty();
            canvas_el = $("<canvas id='canvas-profile' width='" + (image.width - 1) + "' height='" + (image.height - 1) + "'></canvas>");
            $('#canvas-container').append(canvas_el);
            canvas = canvas_el.get(0).getContext('2d');
            canvas.drawImage(image, 0, 0, image.width, image.height);
            image_data = canvas.getImageData(0, 0, image.width, image.height);
            size = 4;
            for (w = 0, _ref = image.width - 1, _step = size; 0 <= _ref ? w <= _ref : w >= _ref; w += _step) {
              for (h = 0, _ref2 = image.height - 1, _step2 = size; 0 <= _ref2 ? h <= _ref2 : h >= _ref2; h += _step2) {
                average = (image_data.data[((image.height * h) + w) * 4] + image_data.data[((image.height * h) + w) * 4 + 1] + image_data.data[((image.height * h) + w) * 4 + 2]) / 3;
                for (i = 0, _ref3 = size - 1; 0 <= _ref3 ? i <= _ref3 : i >= _ref3; 0 <= _ref3 ? i++ : i--) {
                  for (j = 0, _ref4 = size - 1; 0 <= _ref4 ? j <= _ref4 : j >= _ref4; 0 <= _ref4 ? j++ : j--) {
                    if (!(w + j > image.width - 1 || h + i > image.height - 1)) {
                      image_data.data[((image.width * (h + i)) + w + j) * 4] = average;
                      image_data.data[((image.width * (h + i)) + w + j) * 4 + 1] = average + 20;
                      image_data.data[((image.width * (h + i)) + w + j) * 4 + 2] = average;
                    }
                  }
                }
              }
            }
            return canvas.putImageData(image_data, 0, 0);
          },
          error: function(xhr, text_status) {
            return console.log("Error loading profile image: " + text_status);
          }
        });
      });
      socket.on("disconnect", function() {
        $('#header-countwait').html("Trying to reconnect");
        $('#countwait').html("Pease stand by...");
        $('#view-game, #view-prepare, #view-chat').hide();
        $('.display').removeClass('stripes');
        $('#view-wait').fadeIn();
        return started = false;
      });
      return socket.on("connect", function() {
        var id;
        id = socket.socket.sessionid;
        return $.getJSON("/user/auth-socket.json?id=" + id, __bind(function(data) {
          startGame();
          if (loaded) {
            return;
          }
          if (data.success) {
            socket.on("question.prepare", function(question) {
              $('.display').removeClass('stripes');
              if (!started) {
                $('#view-wait').hide();
                $('#view-chat').fadeIn();
                $('#canvas-container').fadeIn();
                setTimeout(function() {
                  return listEntry("System", "Navigate to <a href=\"/highscore\" target=\"_blank\">/highscore</a> for overall score");
                }, 3000);
                started = true;
                loaded = true;
              }
              $('#question-category').text("Next question is about " + question.category);
              $('#question-author').text("by " + question.createdBy);
              $('#view-game').hide();
              return $('#view-prepare').fadeIn();
            });
            socket.on("question.new", function(question) {
              var answer, keys;
              if (!started) {
                return;
              }
              $('#view-prepare').hide();
              $('.display').addClass('stripes');
              $('#view-game').fadeIn();
              $('.selected').removeClass('selected');
              for (answer = 1; answer <= 4; answer++) {
                $('#a' + answer).fadeIn('fast');
              }
              $('#question').text("" + question.text);
              keys = [1, 2, 3, 4];
              keys.sort(randOrd);
              $('#a1').attr("data-answer", keys[0]).removeClass("selected").text(question['a' + keys[0]]);
              $('#a2').attr("data-answer", keys[1]).removeClass("selected").text(question['a' + keys[1]]);
              $('#a3').attr("data-answer", keys[2]).removeClass("selected").text(question['a' + keys[2]]);
              return $('#a4').attr("data-answer", keys[3]).removeClass("selected").text(question['a' + keys[3]]);
            });
            socket.on("answer.correct", function(answer) {
              console.log(answer);
              $('ul#answers li div[data-answer=' + answer + ']').addClass("selected");
              return soundManager.play("correct");
            });
            socket.on("answer.wrong", function(answer) {
              $('ul#answers li div[data-answer=' + answer + ']').addClass("selected");
              return soundManager.play("wrong");
            });
            socket.on("answer.twice", function() {
              return addAlert("You already selected an answer.");
            });
            socket.on("answer.over", function() {
              return addAlert("Time is over.");
            });
            socket.on("question.countdown", function(seconds) {
              if (started) {
                return $('#countdown').html(seconds);
              } else {
                return $('#countwait').html("JOINING IN " + seconds + " SECONDS...");
              }
            });
            socket.on("scoreboard", function(scoreboard) {
              var entry, listEntry, rank, _i, _len, _results;
              $('#scoreboard li').remove();
              rank = 0;
              _results = [];
              for (_i = 0, _len = scoreboard.length; _i < _len; _i++) {
                entry = scoreboard[_i];
                rank += 1;
                _results.push(rank < 11 ? (listEntry = $('<li>').append($('<a>').attr({
                  href: "/profile/" + entry.userId,
                  target: "_blank"
                }).html("" + entry.points + " " + (entry.name.substring(0, 8)))), $('#scoreboard').append(listEntry)) : void 0);
              }
              return _results;
            });
            socket.on("chat.msg", function(result) {
              return listEntry(result.name, result.msg);
            });
            socket.on("badge.new", function(badge) {
              if (badge.badge === 'rampage') {
                addAlert("" + badge.name + " is on a rampage");
              }
              if (badge.badge === 'epic') {
                addAlert("" + badge.name + " knowledge is epic");
              }
              if (badge.badge === "godmode") {
                addAlert("" + badge.name + " is on godmode");
              }
              if (badge.badge === "pawned") {
                addAlert("" + badge.name + " pawned");
              }
              if (badge.badge === "monsterpawned") {
                addAlert("" + badge.name + " monsterpawned");
              }
              if (badge.badge === "failed") {
                addAlert("" + badge.name + " failed");
              }
              if (badge.badge === "epicfail") {
                return addAlert("" + badge.name + " failed epic");
              }
            });
            return socket.on("question.wait", function(result) {
              var answer, correct, _results;
              correct = result.correct;
              if (!started) {
                $('#countwait').html("Good luck!");
              }
              $('#countdown').html("Over");
              _results = [];
              for (answer = 1; answer <= 4; answer++) {
                _results.push(correct !== ("a" + answer) ? $('ul#answers li div[data-answer=' + answer + ']').fadeOut() : void 0);
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
    listEntry = function(name, msg) {
      var message;
      message = $('<li>').html("<div class='message-wrapper'><span class='name'>" + name + ":</span> " + msg + "</div>");
      $('#messages').prepend(message);
      return setTimeout(function() {
        message.css('height', '28px');
        if ($('#messages li').length > 30) {
          return $('#messages li:last-child').remove();
        }
      }, 1);
    };
    addAlert = function(msg) {
      return listEntry("System", msg);
    };
    /* Buttons */
    $(document).keydown(function(event) {
      var key;
      return key = event.keyCode ? event.keyCode : event.which;
    });
    $('#a1, #a2, #a3, #a4').click(function() {
      return sendAnswer($(this).attr("data-answer"));
    });
    /* Chat */
    $('#chat-form').bind('submit', function(e) {
      var message;
      e.preventDefault();
      if (socket == null) {
        return;
      }
      message = $('#chat-msg').val();
      $('#chat-msg').val("");
      return socket.emit('chat.msg', {
        content: message
      });
    });
    /* Views */
    $('#view-game, #view-prepare, #header-countwait, #view-chat').hide();
    /* intro */
    $('.view-content .view-wait').show();
    intro = new Intro($('.display'));
    return intro.start(__bind(function() {
      $('#header-countwait').show();
      /* start game */
      return connect();
    }, this));
  });
}).call(this);
