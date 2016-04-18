var BLOCK_SIZE = require('../util/constants').BLOCK_SIZE;

function Block(game, posX, posY) {
    this.game = game;
    this.position = {
        x: posX,
        y: posY
    };

    this.sprite = new Image;
    this.sprite.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAaklEQVRYR+3XOQ7AIAxE0XD/4yQVS8HJjIRkCqdIBVPkUyMYP7mZZGZ2Cc5T2/w1/S6AT95z1wh8BvALu9bCJ/f3XztAAAQQQAABBBBAAAEEEJAJxMKwqxfEd1cvkAW4S53tODaWYwLqAAMAoAJYuhkgzQAAAABJRU5ErkJgggAA';
}

Block.prototype.draw = function() {
    var startX = this.position.x * BLOCK_SIZE;
    var startY = this.position.y * BLOCK_SIZE;
    this.game.ctx.drawImage(this.sprite, startX, startY, BLOCK_SIZE, BLOCK_SIZE);
};

Block.prototype.update = function() {};

module.exports = Block;
