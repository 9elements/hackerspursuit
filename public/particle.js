(function() {
  var Particle;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Particle = (function() {
    function Particle(type, position, pixel, staticIntro) {
      if (type == null) {
        type = null;
      }
      if (position == null) {
        position = null;
      }
      this.draw = __bind(this.draw, this);
      this.update = __bind(this.update, this);
      switch (type) {
        case 'func':
          this.dir = {
            x: Math.random() < 0.5 ? 1 : -1,
            y: Math.random() < 0.5 ? 1 : -1
          };
          this.speed = Math.pow(Math.random() + Intro.MIN_SPEED, 2) * Intro.MAX_SPEED;
          this.power = {
            x: 2,
            y: 2
          };
          this.stauchung = {
            x: Math.pow(Math.random() + Intro.MIN_SPEED, 2),
            y: Math.pow(Math.random() + Intro.MIN_SPEED, 2)
          };
          if (Math.random() > 0.5) {
            this.func_in = this.inVertical;
          } else {
            this.func_in = this.inHorizontal;
          }
          this.func_out = this.out;
          this.drawPosition = this.pos = position;
          this.pixel = pixel;
          this.staticIntro = staticIntro;
      }
    }
    Particle.prototype.inVertical = function() {
      return {
        x: this.pos.x,
        y: this.stauchung.y * Math.pow(Intro.TIME, this.power.y) * this.dir.y * this.speed + this.pos.y
      };
    };
    Particle.prototype.inHorizontal = function() {
      return {
        x: this.stauchung.x * Math.pow(Intro.TIME, this.power.x) * this.dir.x * this.speed + this.pos.x,
        y: this.pos.y
      };
    };
    Particle.prototype.out = function() {
      return {
        x: this.stauchung.x * Math.pow(Intro.TIME, this.power.x) * this.dir.x * this.speed + this.pos.x,
        y: this.stauchung.y * Math.pow(Intro.TIME, this.power.y) * this.dir.y * this.speed + this.pos.y
      };
    };
    Particle.prototype.update = function() {
      var newValue;
      switch (Intro.animationPhase) {
        case 'logo_in':
          if (!this.staticIntro) {
            return this.drawPosition = this.func_in();
          }
          break;
        case 'type_in':
          if (this.staticIntro) {
            return this.pixel[3] = Intro.FRAME / Intro.animationPhaseEnd['type_in'].end + 0.02;
          }
          break;
        case 'out':
          this.drawPosition = this.func_out();
          if (this.pixel[3] > 0) {
            newValue = this.pixel[3] * 0.97;
          }
          return this.pixel = [this.pixel[0], this.pixel[1], this.pixel[2], newValue];
      }
    };
    Particle.prototype.draw = function() {
      Intro.CTX.strokeStyle = 'rgba(0,255,0,255)';
      Intro.CTX.fillStyle = "rgba(" + this.pixel[0] + "," + this.pixel[1] + "," + this.pixel[2] + "," + this.pixel[3] + ")";
      return Intro.CTX.fillRect(this.drawPosition.x, this.drawPosition.y, Intro.PARTICLE_SIZE, Intro.PARTICLE_SIZE);
    };
    return Particle;
  })();
  window.Particle = Particle;
}).call(this);
