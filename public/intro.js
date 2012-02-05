(function() {
  window.Intro = {
    start: function(container, callback) {
      var animationFinished, i, main_loop;
      window.WIDTH = $(container).width();
      window.HEIGHT = $(container).height();
      window.CANVAS = $("<canvas width='" + WIDTH + "' height='" + HEIGHT + "'></canvas>");
      window.CANVAS.appendTo($(container));
      $(container).css('padding-bottom', 0);
      window.CTX = window.CANVAS.get(0).getContext('2d');
      window.START = -300;
      window.FRAME = START;
      window.END = 500;
      window.TIME = 0;
      window.PARTICLES = [];
      window.MAX_SPEED = 0.8;
      window.MIN_SPEED = 0.05;
      window.PAUSE = 100;
      window.BORDER = 400;
      window.MAX_RADIUS = 250;
      window.MIN_RADIUS = 100;
      window.NUM_CIRCLES = 1;
      window.EXPLOSION_POWER = 7;
      window.CIRCLE_DENSITY = 4;
      window.PARTICLES_PER_POINT = 1;
      window.PARTICLE_SIZE = 2;
      window.FWD = true;
      window.animationPhase = 'logo_in';
      window.animationPhaseEnd = {
        'logo_in': {
          start: -400,
          end: 0
        },
        'pause1': {
          start: 0,
          end: 60
        },
        'type_in': {
          start: 0,
          end: 100
        },
        'pause2': {
          start: 0,
          end: 60
        },
        'out': {
          start: 0,
          end: 200
        }
      };
      main_loop = function() {
        var nextEnd, particle, _i, _len, _results;
        window.window.FRAME += 1;
        nextEnd = window.animationPhaseEnd[window.animationPhase].end;
        switch (window.animationPhase) {
          case 'logo_in':
            if (window.FRAME === nextEnd) {
              console.log('logo_in is over, switching to pause1');
              window.animationPhase = 'pause1';
              window.FRAME = window.animationPhaseEnd['pause1'].start;
            }
            break;
          case 'pause1':
            if (window.FRAME === nextEnd) {
              console.log('switching to type_in');
              window.animationPhase = 'type_in';
              window.FRAME = window.animationPhaseEnd['type_in'].start;
            }
            break;
          case 'type_in':
            if (window.FRAME === nextEnd) {
              console.log('switching to puase2');
              window.animationPhase = 'pause2';
              window.FRAME = window.animationPhaseEnd['pause2'].start;
            }
            break;
          case 'pause2':
            if (window.FRAME === nextEnd) {
              console.log('switching to out');
              window.animationPhase = 'out';
              window.FRAME = window.animationPhaseEnd['out'].start;
            }
            break;
          case 'out':
            if (window.FRAME === nextEnd) {
              console.log('end');
              clearInterval(INTERVAL);
              animationFinished();
            }
        }
        if (window.FRAME < 1) {
          window.TIME = 0.06 * Math.pow(window.FRAME, 2);
        } else {
          window.TIME = 2 + Math.log(window.FRAME) * EXPLOSION_POWER;
        }
        CTX.clearRect(0, 0, WIDTH, HEIGHT);
        _results = [];
        for (_i = 0, _len = PARTICLES.length; _i < _len; _i++) {
          particle = PARTICLES[_i];
          particle.update();
          _results.push(particle.draw());
        }
        return _results;
      };
      animationFinished = function() {
        $(container).css('padding-bottom', '20px');
        return callback();
      };
      i = new PImage;
      i.init();
      return window.INTERVAL = setInterval(main_loop, 1000 / 50);
    }
  };
}).call(this);
