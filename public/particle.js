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
          this.func_in = this.inBoth;
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
    Particle.prototype.inBoth = function() {
      return {
        x: this.stauchung.x * Math.pow(Intro.TIME, this.power.x) * this.dir.x * this.speed + this.pos.x,
        y: this.stauchung.y * Math.pow(Intro.TIME, this.power.y) * this.dir.y * this.speed + this.pos.y
      };
    };
    Particle.prototype.out = function() {
      return {
        x: this.stauchung.x * Math.pow(Intro.TIME, this.power.x) * this.dir.x * this.speed + this.pos.x,
        y: this.stauchung.y * Math.pow(Intro.TIME, this.power.y) * this.dir.y * this.speed + this.pos.y
      };
    };
    Particle.prototype.rotate = function() {
      var delta_x, rotationFactor;
      rotationFactor = Math.sin(Intro.rotationFrame * 0.03);
      delta_x = Intro.canvasCenter.x - this.pos.x;
      return {
        x: Math.round(Intro.canvasCenter.x + delta_x * rotationFactor) - 3,
        y: this.pos.y
      };
    };
    Particle.prototype.rotationOffset = function() {
      var rotatedPosition;
      rotatedPosition = this.rotate();
      return {
        x: this.pos.x - rotatedPosition.x,
        y: 0
      };
    };
    Particle.prototype.waveOffset = function() {
      var delta, index, offset, t, t_delta;
      offset = {
        x: 0,
        y: 0
      };
      t = Intro.FRAME * 4 + 200;
      t_delta = 40;
      index = this.pos.x + (this.pos.y - 200) * 0.8;
      if (((t - t_delta) < index && index < (t + t_delta))) {
        delta = index - t;
        offset = {
          x: 0,
          y: -(Math.pow(delta, 2) * 0.002) + 3
        };
      }
      return offset;
    };
    Particle.prototype.rasterizeAlpha = function(alpha) {
      var newAlpha;
      newAlpha = alpha * 100;
      newAlpha = Math.floor(newAlpha / 16) * 16;
      return newAlpha / 100;
    };
    Particle.prototype.update = function() {
      var alpha, rotationOffset, waveOffset;
      this.drawPosition = {
        x: this.pos.x,
        y: this.pos.y
      };
      switch (Intro.animationPhase) {
        case 'logo_in':
          if (!this.staticIntro) {
            this.drawPosition = this.func_in();
          }
          break;
        case 'type_in':
          if (this.staticIntro) {
            this.pixel[3] = Intro.FRAME / Intro.animationPhaseEnd['type_in'].end + 0.02;
          }
          break;
        case 'out':
          this.drawPosition = this.func_out();
          if (this.pixel[3] > 0) {
            alpha = this.pixel[3] * 0.97;
          }
          this.pixel = [this.pixel[0], this.pixel[1], this.pixel[2], alpha];
          break;
        case 'wave':
          if (this.staticIntro) {
            waveOffset = this.waveOffset();
            this.drawPosition.x -= waveOffset.x;
            this.drawPosition.y -= waveOffset.y;
          }
          break;
        case 'fade_out':
          this.pixel[3] = this.pixel[3] * 0.95;
      }
      if (!this.staticIntro && Intro.rotationFrame !== null) {
        rotationOffset = this.rotationOffset();
        this.drawPosition.x -= rotationOffset.x;
        return this.drawPosition.y -= rotationOffset.y;
      }
    };
    Particle.prototype.draw = function() {
      Intro.CTX.strokeStyle = 'rgba(0,255,0,255)';
      Intro.CTX.fillStyle = "rgba(" + this.pixel[0] + "," + this.pixel[1] + "," + this.pixel[2] + "," + (this.rasterizeAlpha(this.pixel[3])) + ")";
      this.drawPosition.x = Math.floor(this.drawPosition.x / 2) * 2;
      this.drawPosition.y = Math.floor(this.drawPosition.y / 2) * 2;
      return Intro.CTX.fillRect(this.drawPosition.x, this.drawPosition.y, Intro.PARTICLE_SIZE, Intro.PARTICLE_SIZE);
    };
    return Particle;
  })();
  window.Particle = Particle;
}).call(this);
