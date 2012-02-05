(function() {
  var PImage;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  PImage = (function() {
    function PImage() {
      this.init = __bind(this.init, this);
    }
    PImage.prototype.url = '/img/9pixelments.png';
    PImage.prototype.init = function() {
      this.image = document.createElement('img');
      this.image.src = this.url;
      return $(this.image).load(__bind(function() {
        return this.pre_process();
      }, this));
    };
    PImage.prototype.pre_process = function() {
      Intro.CTX.drawImage($(this.image).get(0), 0, 0);
      this.img_data = Intro.CTX.getImageData(0, 0, this.image.width, this.image.height);
      Intro.CTX.clearRect(0, 0, Intro.CANVAS.width(), Intro.CANVAS.height());
      this.img_offset = {
        x: Math.floor($('canvas').width() / 2) - this.image.width * Intro.PARTICLE_SIZE / 2,
        y: Math.floor($('canvas').height() / 2) - this.image.height * Intro.PARTICLE_SIZE / 2
      };
      return this.createPixels();
    };
    PImage.prototype.createPixels = function() {
      var i, index, isStatic, pixel, point, _ref, _results;
      _results = [];
      for (i = 0, _ref = this.img_data.data.length / 4; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        index = i * 4;
        _results.push(this.img_data.data[index] === 0 ? (point = {
          x: (i % this.image.width) * Intro.PARTICLE_SIZE + this.img_offset.x,
          y: Math.floor(i / this.image.width) * Intro.PARTICLE_SIZE + this.img_offset.y
        }, Math.floor(i / this.image.width) > 40 ? isStatic = true : void 0, pixel = [86, 96, 80, isStatic ? 0 : 1], Intro.PARTICLES.push(new Particle('func', point, pixel, isStatic))) : void 0);
      }
      return _results;
    };
    return PImage;
  })();
  window.PImage = PImage;
}).call(this);
