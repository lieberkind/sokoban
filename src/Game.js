var DIRECTIONS = require('./util/constants').DIRECTIONS;

var Block = require('./gameObjects/Block');
var Crate = require('./gameObjects/Crate');
var GoalField = require('./gameObjects/GoalField');
var Player = require('./gameObjects/Player');

function Game(ctx, eventEmitter) {
    var self = this;

    this.ctx = ctx;
    this.eventEmitter = eventEmitter;
    this.gameObjects = [];
    this.pressedDirection = DIRECTIONS.none;

    this.eventEmitter.on('arrowKey.pressed', function(direction) {
        self.setPressedDirection(direction);
        self.update();
        self.resetInputs();
    });
}

Game.prototype.update = function() {
    this.gameObjects.forEach(function(gameObject) {
        gameObject.update();
    });
    if(this.levelWon()) {
        this.eventEmitter.emit('level.won', undefined);
    }
};

Game.prototype.draw = function() {
    this.ctx.clearRect(0, 0, this.ctx.canvas.width, this.ctx.canvas.height);
    this.gameObjects.forEach(function(gameObject) {
        gameObject.draw();
    });
};

Game.prototype.resetInputs = function() {
    this.pressedDirection = DIRECTIONS.none;
};

Game.prototype.getPressedDirection = function() {
    return this.pressedDirection;
};

Game.prototype.setPressedDirection = function(direction) {
    this.pressedDirection = direction;
};

Game.prototype.loadLevel = function(level) {
    var self = this;
    this.level = level;

    this.gameObjects = [];

    level.grid.forEach(function(row, rowIdx) {
        row.forEach(function(field, fieldIdx) {
            if(level.isBlock({x: fieldIdx, y: rowIdx})) {
                self.addGameObject(new Block(self, fieldIdx, rowIdx));       
            }

            if(level.isGoalField({x: fieldIdx, y: rowIdx})) {
                self.addGameObject(new GoalField(self, fieldIdx, rowIdx));
            }
        });
    });

    level.crates.forEach(function(cratePosition) {
        self.addGameObject(new Crate(self, cratePosition.x, cratePosition.y));
    });

    this.addGameObject(new Player(this, level.player.x, level.player.y));
}

Game.prototype.getCurrentLevel = function() {
    if(!this.level) {
        throw new Error('No level loaded.');
    }

    return this.level;
};

Game.prototype.addGameObject = function(obj) {
    this.gameObjects.push(obj);
};

Game.prototype.getGameObjectsOfType = function(type) {
    return this.gameObjects.filter(function(gameObject) {
        return gameObject.constructor === type;
    });
}

Game.prototype.levelWon = function() {
    var goalFields = this.getGameObjectsOfType(GoalField);

    return goalFields.every(function(goalField) {
        return goalField.hasCrate();
    });
};

module.exports = Game;
