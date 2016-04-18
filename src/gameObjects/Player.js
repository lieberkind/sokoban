var BLOCK_SIZE = require('../util/constants').BLOCK_SIZE;
var helpers = require('../util/functions');

var Crate = require('./Crate');

function Player(game, posX, posY) {
    var that = this;

    this.game = game;
    this.position = {
        x: posX,
        y: posY
    }

    var sprite1 = new Image;        
    sprite1.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA70lEQVRYR+2XURKAIAhE9f6HtqnJmUJWWCPto/4ygscGmDmNXwW8mhmXlLFw/A5AKelwnHNCcMdzGV0xvi0hv817XwZQM5ffGykRocBcgKaS2XIFJSprC9bAMoBL4JvkkrQmiNarH6s7esIuA+j2eRGp1wzkurc7NAWWAbjajJnzmq3M+Hq/DGBKYFQTuwI/wHIF6ufx7vNUI1j/DWYXsHuQpGMAukpQaSvGaE9wT8KZAKFKhO2Gowo8AXikhBW487/Q5Do0JyIBKCW8gRkFPgPATkzXDHMZaWdCa8LtpztP57iMgKN3Dqce6tMmBGAD3QtmGY9VnUMAAAAASUVORK5CYIIA';

    sprite2 = new Image;
    sprite2.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA90lEQVRYR+2XwRLDIAhE9f8/2kyZaFsE2U1i9dDcYlAf64KTnK4/xZmamSWpYLXwXIBSkmyQc9KQMq53NzKRocE6ko+rwI4AZub6vDu5TqkMJWkF1gC0DFm7KpNcVmAZQDV65Pb63SwV2+VfoSNhoXKbATA229vVcjpNIW/8PEOvT1gKLAOAyozp81aszvjzfRnATzb2OuZLgT/AcgXq8UCNh62CqJOGVcDeQRqQARgq0WVe+utupM5znbBhzgPglAhM4WVep9G3IWvCOwC3lIg2RhTYBoACQTNnFNgGgO2YUA+DgpTz0ZYNrQ0FOaU39+cUqPdHAA6h4GgZpdYA/gAAAABJRU5ErkJgggAA';

    sprite3 = new Image;
    sprite3.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA/ElEQVRYR+2X4Q7DIAiE5f0f2qWNNB3l5DA6t2T908QifD0QVcr4U8FUybhMGRvHawBqLadjkYLgzu82umP8NoT8PuZ9M4D75zbfSIkZCnwW4FHJ2XIFJWprC9bANoBbYEryaM1Hq6Mn7DaAfuCWW2noV6rReJMIKeEpsA2AktwSqwJoPOoT93nbAKjAUbVnv+ufH+8/wHYFNH3sPp9Kd3RuCFdBdg+ydBmArhKX44pOYtryfOSJnXA9wJgSujmYHKzbDW0qFgBwSvCXA7c4mCIf6hOR9MrNAKSUYAP/JEC2Y1LqUkbenTDqcMftjunZlBFwtOZyylA3mykALw46bhmB1MFZAAAAAElFTkSuQmCC';

    sprite4 = new Image;
    sprite4.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAABB0lEQVRYR9WW2w7EIAhE5f8/2k3d2ChyGUzVdl82aZUehgGlNP/LylaKhAwtZoHXAOScSmCipMGV9/zrwuLukRZ32PdmADFzXm9NiScU2AswODlqV8Wi3FuqB44BNB/uJJ8VwOsOK+4xALvPa205OnuOzglJgWMAZpvNesCbE23cYwDQgImccMjamvn1/w2ApzxQ1QkrsBKgQkHnfM7aPeQfhqhH9eaB2wXDvFkIAClh55/ua5SX+SVWUUxoGbMUOwAwJVgpau3RzHk3SLPDVmIDAKREt6hJw7sHIAq8BsAE8U47xej3tsiAg84MVPpICXiS0MT0Mv80gGb8qaQiHhBLIQyQUMwfGRx6GRgbXCgAAAAASUVORK5CYIIA';

    this.sprites = [sprite1, sprite2, sprite3, sprite4, sprite3, sprite2];
    this.spriteIndex = 0;

    var t = setInterval(function() {
        var isLastSprite = that.spriteIndex === that.sprites.length - 1;
        that.spriteIndex = isLastSprite ? 0 : that.spriteIndex + 1;
    }, 300);
}

Player.prototype.canMove = function(direction) {
    var dPosition = helpers.getNextPosition(this.position, direction);

    var crates = this.game.getGameObjectsOfType(Crate);

    var canMoveCrate = crates.reduce(function(canMoveCrate, crate) {
        if(helpers.isSamePosition(crate.position, dPosition)) {
            return canMoveCrate && crate.canMove(direction);
        }
        return canMoveCrate;
    }, true);

    return this.game.getCurrentLevel().isWithinMaze(dPosition) && canMoveCrate;
};

Player.prototype.move = function(direction) {
    var self = this;

    this.position = helpers.getNextPosition(this.position, direction);

    var crates = this.game.getGameObjectsOfType(Crate);

    crates.forEach(function(crate) {
        if(helpers.isSamePosition(self.position, crate.position)) {
            crate.move(direction);
        }
    });

    this.game.eventEmitter.emit('player.moved');
};

Player.prototype.draw = function() {
    var startX = this.position.x * BLOCK_SIZE;
    var startY = this.position.y * BLOCK_SIZE;
    this.game.ctx.drawImage(this.sprites[this.spriteIndex], startX, startY, BLOCK_SIZE, BLOCK_SIZE);
};

Player.prototype.update = function() {
    var direction;

    direction = this.game.getPressedDirection();

    if(this.canMove(direction)) {
        this.move(direction);
    }
}

module.exports = Player;
