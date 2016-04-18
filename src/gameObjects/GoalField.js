var BLOCK_SIZE = require('../util/constants').BLOCK_SIZE;
var helpers = require('../util/functions');
var Crate = require('./Crate');

function GoalField(game, posX, posY) {
    this.game = game;
    this.position = {
        x: posX,
        y: posY
    };

    this.sprite = new Image;
    this.sprite.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAYklEQVRYR+3VywoAIAhEUf3/jzYi2rjTgR5w3UvjIdTNLOxiOQEQQAABBL4ViFgnxH1u8361b8EzAfLsVRFZ4HiATa8+vPvLAtcD5MnVz1gWeC5AfwOsTlmAAAgggAACqsAA1gU4AQHGir0AAAAASUVORK5CYIIA';
}

GoalField.prototype.hasCrate = function() {
    var self = this;

    var crates = this.game.getGameObjectsOfType(Crate);

    return crates.some(function(crate) {
        return helpers.isSamePosition(self.position, crate.position);
    })
};

GoalField.prototype.update = function() {}

GoalField.prototype.draw = function() {
    var startX = this.position.x * BLOCK_SIZE;
    var startY = this.position.y * BLOCK_SIZE;
    this.game.ctx.drawImage(this.sprite, startX, startY, BLOCK_SIZE, BLOCK_SIZE);
};

module.exports = GoalField;
