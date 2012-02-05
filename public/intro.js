(function() {
  var Intro;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Intro = (function() {
    Intro.PARTICLE_SIZE = 2;
    Intro.MAX_SPEED = 0.8;
    Intro.MIN_SPEED = 0.05;
    Intro.animationPhase = 'logo_in';
    Intro.TIME = 0;
    Intro.PARTICLES = [];
    Intro.animationPhaseEnd = {
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
    function Intro(container) {
      this.main_loop = __bind(this.main_loop, this);      var i;
      this.container = container;
      i = new PImage;
      i.init();
    }
    Intro.prototype.start = function(callback) {
      this.callback = callback;
      this.WIDTH = $(this.container).width();
      this.HEIGHT = $(this.container).height();
      $(this.container).css('padding-bottom', 0);
      this.START = -300;
      this.PAUSE = 100;
      this.EXPLOSION_POWER = 7;
      Intro.CANVAS = $("<canvas width='" + this.WIDTH + "' height='" + this.HEIGHT + "'></canvas>");
      Intro.CANVAS.appendTo($(this.container));
      Intro.CTX = Intro.CANVAS.get(0).getContext('2d');
      Intro.FRAME = this.START;
      return this.INTERVAL = setInterval(this.main_loop, 1000 / 50);
    };
    Intro.prototype.main_loop = function() {
      var nextEnd, particle, _i, _len, _ref, _results;
      Intro.FRAME += 1;
      nextEnd = Intro.animationPhaseEnd[Intro.animationPhase].end;
      switch (Intro.animationPhase) {
        case 'logo_in':
          if (Intro.FRAME === nextEnd) {
            Intro.animationPhase = 'pause1';
            Intro.FRAME = Intro.animationPhaseEnd['pause1'].start;
          }
          break;
        case 'pause1':
          if (Intro.FRAME === nextEnd) {
            Intro.animationPhase = 'type_in';
            Intro.FRAME = Intro.animationPhaseEnd['type_in'].start;
          }
          break;
        case 'type_in':
          if (Intro.FRAME === nextEnd) {
            Intro.animationPhase = 'pause2';
            Intro.FRAME = Intro.animationPhaseEnd['pause2'].start;
          }
          break;
        case 'pause2':
          if (Intro.FRAME === nextEnd) {
            Intro.animationPhase = 'out';
            Intro.FRAME = Intro.animationPhaseEnd['out'].start;
          }
          break;
        case 'out':
          if (Intro.FRAME === nextEnd) {
            clearInterval(this.INTERVAL);
            this.animationFinished();
          }
      }
      if (Intro.FRAME < 1) {
        Intro.TIME = 0.06 * Math.pow(Intro.FRAME, 2);
      } else {
        Intro.TIME = 2 + Math.log(Intro.FRAME) * this.EXPLOSION_POWER;
      }
      Intro.CTX.clearRect(0, 0, this.WIDTH, this.HEIGHT);
      _ref = Intro.PARTICLES;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        particle = _ref[_i];
        particle.update();
        _results.push(particle.draw());
      }
      return _results;
    };
    Intro.prototype.animationFinished = function() {
      $(container).css('padding-bottom', '20px');
      Intro.CANVAS.remove();
      return this.callback();
    };
    return Intro;
  })();
  window.Intro = Intro;
}).call(this);
