var BLOCK_SIZE = require('../util/constants').BLOCK_SIZE;
var helpers = require('../util/functions');

function Crate(game, posX, posY) {
    this.game = game;
    this.position = {
        x: posX,
        y: posY
    };

    this.sprite = new Image;
    this.sprite.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAwklEQVRYR+2W2w2AIAwAYThmUSdSZ2E4jMQmyFtsLTH4SaS9XqBFCuZPMucXNQCGCNLm7hrAVr4KhSJgEdqPUzTABkCSWO2bNaCnGUwkDbABkJx2qBzKzhnoA8AgYcjrgj820C8AtKxKQ/gG2ABSzbpgAs8AG0DNmDovd8LEewPsALeOHRmI/z8Dw8AwgGzAfwfEwtuLFUxDpE7YDtD4JoZO6GyPluIuxg18DdCYL7ct29QDA5wABLnLIWtnXjlS4x8HfjeSIYxtab0AAAAASUVORK5CYIIA';
};

Crate.prototype.canMove = function(direction) {
    var dPosition = helpers.getNextPosition(this.position, direction);

    var crates = this.game.getGameObjectsOfType(Crate);

    var crateIsBlocking = false;

    crates.forEach(function(crate) {
        if(crate.position.x === dPosition.x && crate.position.y === dPosition.y) {
            crateIsBlocking = true;
        }
    });

    return this.game.getCurrentLevel().isWithinMaze(dPosition) && !crateIsBlocking;
};

Crate.prototype.move = function(direction) {
    this.position = helpers.getNextPosition(this.position, direction);
    this.game.eventEmitter.emit('crate.moved');
};

Crate.prototype.update = function() {};

Crate.prototype.draw = function() {
    var startX = this.position.x * BLOCK_SIZE;
    var startY = this.position.y * BLOCK_SIZE;
    this.game.ctx.drawImage(this.sprite, startX, startY, BLOCK_SIZE, BLOCK_SIZE);
};

module.exports = Crate;
