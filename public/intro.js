(function() {
  var Intro, intro;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Intro = (function() {
    Intro.PARTICLE_SIZE = 2;
    Intro.MAX_SPEED = 0.8;
    Intro.MIN_SPEED = 0.05;
    Intro.animationPhase = 'logo_in';
    Intro.TIME = 0;
    Intro.PARTICLES = [];
    Intro.prototype.animationPhases = ['pause1', 'type_in', 'wave', 'pause3', 'fade_out'];
    Intro.animationPhaseEnd = {
      'logo_in': {
        start: -400,
        end: 0
      },
      'pause1': {
        start: 0,
        end: 30
      },
      'type_in': {
        start: 0,
        end: 100
      },
      'pause2': {
        start: 0,
        end: 60
      },
      'wave': {
        start: 0,
        end: 80
      },
      'pause3': {
        start: 0,
        end: 30
      },
      'out': {
        start: 0,
        end: 180
      },
      'fade_out': {
        start: 0,
        end: 150
      }
    };
    Intro.rotationFrame = 16;
    function Intro(container) {
      this.main_loop = __bind(this.main_loop, this);      var i;
      this.container = container;
      Intro.canvasCenter = {
        x: $(this.container).width() / 2,
        y: $(this.container).height() / 2
      };
      i = new PImage;
      i.init();
    }
    Intro.prototype.start = function(callback) {
      this.callback = callback;
      this.WIDTH = $(this.container).width();
      this.HEIGHT = $(this.container).height();
      this.START = -250;
      this.PAUSE = 100;
      this.EXPLOSION_POWER = 7;
      Intro.CANVAS = $("<canvas id='canvas-intro' width='" + this.WIDTH + "' height='" + this.HEIGHT + "'></canvas>");
      Intro.CANVAS.appendTo($(this.container));
      Intro.CTX = Intro.CANVAS.get(0).getContext('2d');
      Intro.FRAME = this.START;
      return this.INTERVAL = setInterval(this.main_loop, 1000 / 50);
    };
    Intro.prototype.main_loop = function() {
      var nextEnd, particle, _i, _len, _ref, _results;
      Intro.FRAME += 1;
      if (Intro.rotationFrame !== null) {
        Intro.rotationFrame += 1;
      }
      nextEnd = Intro.animationPhaseEnd[Intro.animationPhase].end;
      if (Intro.FRAME === nextEnd) {
        if (Intro.animationPhase === 'fade_out') {
          clearInterval(this.INTERVAL);
          this.animationFinished();
          return;
        }
        if (Intro.animationPhase === 'wave') {
          Intro.rotationFrame = null;
        }
        Intro.animationPhase = this.animationPhases.shift();
        Intro.FRAME = Intro.animationPhaseEnd[Intro.animationPhase].start;
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
      Intro.CANVAS.remove();
      return this.callback();
    };
    return Intro;
  })();
  window.Intro = Intro;
  intro = new Intro($('.display'));
  intro.start(__bind(function() {
    return $('#view-login').fadeIn();
  }, this));
}).call(this);
