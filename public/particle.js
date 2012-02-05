(function() {
  var Particle;
  Particle = (function() {
    function Particle(type, position, pixel, staticIntro) {
      var dir, power, speed, stauchung;
      if (type == null) {
        type = null;
      }
      if (position == null) {
        position = null;
      }
      switch (type) {
        case 'func':
          dir = {
            x: Math.random() < 0.5 ? 1 : -1,
            y: Math.random() < 0.5 ? 1 : -1
          };
          speed = Math.pow(Math.random() + MIN_SPEED, 2) * MAX_SPEED;
          power = {
            x: 2,
            y: 2
          };
          stauchung = {
            x: Math.pow(Math.random() + MIN_SPEED, 2),
            y: Math.pow(Math.random() + MIN_SPEED, 2)
          };
          if (Math.random() > 0.5) {
            this.func_in = function(time) {
              return {
                x: position.x,
                y: stauchung.y * Math.pow(time, power.y) * dir.y * speed + position.y
              };
            };
          } else {
            this.func_in = function(time) {
              return {
                x: stauchung.x * Math.pow(time, power.x) * dir.x * speed + position.x,
                y: position.y
              };
            };
          }
          this.func_out = function(time) {
            return {
              x: stauchung.x * Math.pow(time, power.x) * dir.x * speed + position.x,
              y: stauchung.y * Math.pow(time, power.y) * dir.y * speed + position.y
            };
          };
          this.pos = position;
          this.pixel = pixel;
          this.staticIntro = staticIntro;
      }
    }
    Particle.prototype.update = function() {
      var current, duration, newValue;
      switch (window.animationPhase) {
        case 'logo_in':
          if (!this.staticIntro) {
            return this.pos = this.func_in(TIME);
          }
          break;
        case 'type_in':
          if (this.staticIntro) {
            duration = window.animationPhaseEnd['type_in'].end;
            current = window.FRAME / duration + 0.02;
            return this.pixel[3] = current;
          }
          break;
        case 'pause':
          break;
        case 'out':
          this.pos = this.func_out(TIME);
          if (this.pixel[3] > 0) {
            newValue = this.pixel[3] * 0.97;
          }
          return this.pixel = [this.pixel[0], this.pixel[1], this.pixel[2], newValue];
      }
    };
    Particle.prototype.draw = function() {
      CTX.strokeStyle = 'rgba(0,255,0,255)';
      CTX.fillStyle = "rgba(" + this.pixel[0] + "," + this.pixel[1] + "," + this.pixel[2] + "," + this.pixel[3] + ")";
      return CTX.fillRect(this.pos.x, this.pos.y, PARTICLE_SIZE, PARTICLE_SIZE);
    };
    return Particle;
  })();
  window.Particle = Particle;
}).call(this);
