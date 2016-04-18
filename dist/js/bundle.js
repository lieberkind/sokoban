(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
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

},{"./gameObjects/Block":3,"./gameObjects/Crate":4,"./gameObjects/GoalField":5,"./gameObjects/Player":6,"./util/constants":11}],2:[function(require,module,exports){
function Level(level) {
    this.grid = level.grid.map(function(row) {
        return row.split("");
    });
    this.crates = level.crates;
    this.player = level.player;
}

Level.prototype.isBlock = function(position) {
    return this.grid[position.y][position.x] === '#';
};

Level.prototype.isGoalField = function(position) {
    return this.grid[position.y][position.x] === 'x';
}

Level.prototype.isWithinMaze = function(position) {
    return position.x < this.grid[position.y].length &&
        position.x >= 0 &&
        position.y < this.grid.length &&
        position.y >= 0 &&
        !this.isBlock(position);
};

module.exports = Level;

},{}],3:[function(require,module,exports){
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

},{"../util/constants":11}],4:[function(require,module,exports){
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

},{"../util/constants":11,"../util/functions":12}],5:[function(require,module,exports){
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

},{"../util/constants":11,"../util/functions":12,"./Crate":4}],6:[function(require,module,exports){
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

},{"../util/constants":11,"../util/functions":12,"./Crate":4}],7:[function(require,module,exports){
module.exports={
    "grid": [
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",
        "##############...x#",
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",
    ],
    "crates": [
        { "x": 15, "y": 9},
    ],
    "player": { "x": 14, "y": 9 }
}

},{}],8:[function(require,module,exports){
module.exports={
    "grid": [
        "###################",
        "###################",
        "###################",
        "#####...###########",
        "#####...###########",
        "#####...###########",
        "###......##########",
        "###.#.##.##########",
        "#...#.##.#####..xx#",
        "#...............xx#",
        "#####.###.#.##..xx#",
        "#####.....#########",
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",
    ],
    "crates": [
        { "x": 5, "y": 4},
        { "x": 7, "y": 5},
        { "x": 7, "y": 6},
        { "x": 5, "y": 6},
        { "x": 5, "y": 9},
        { "x": 2, "y": 9},
    ],
    "player": { "x": 11, "y": 10 }
}

},{}],9:[function(require,module,exports){
module.exports={
    "grid": [
        "###################",
        "###################",
        "###################",
        "###################",
        "####xx..#.....#####",
        "####xx..#.......###",
        "####xx..#.####..###",
        "####xx......##..###",
        "####xx..#.#....####",
        "#########.##....###",
        "######..........###",
        "######....#.....###",
        "###################",
        "###################",
        "###################",
        "###################",
        "###################",  
    ],
    "crates": [
        { "x": 9, "y": 6},
        { "x": 10, "y": 5},
        { "x": 13, "y": 5},
        { "x": 7, "y": 10},
        { "x": 10, "y": 10},
        { "x": 12, "y": 10},
        { "x": 14, "y": 10},
        { "x": 14, "y": 9},
        { "x": 12, "y": 9},
        { "x": 13, "y": 8},
    ],
    "player": { "x": 10, "y": 7 }
}

},{}],10:[function(require,module,exports){
var consts = require('./util/constants');
var helpers = require('./util/functions');
var Game = require('./Game');
var Level = require('./Level');

var LEVELS = [
    require('./levels/level0.json'),
    require('./levels/level1.json'),
    require('./levels/level2.json')
];
var eventEmitter = helpers.createEventEmitter();

// Get Context
var canvas = document.getElementById('game');
canvas.width = 608;
canvas.height = 544;
var context = canvas.getContext('2d');
context.scale(2, 2);

// Create new game
var game = new Game(context, eventEmitter);
game.loadLevel(new Level(LEVELS[0]));

eventEmitter.on('level.won', function() {
    window.requestAnimationFrame(function() {
        window.requestAnimationFrame(function() {
            alert('Kneeep');
        
            var nextLevelIdx = 1;
            game.loadLevel(new Level(LEVELS[nextLevelIdx]));
        });
    });
});

var moves = 0;
eventEmitter.on('player.moved', function() {
    var movesElm = document.querySelector('[moves]');
    movesElm.innerHTML = 'Moves: ' + ++moves;
});

var pushes = 0;
eventEmitter.on('crate.moved', function() {
    var pushesElm = document.querySelector('[pushes]');
    pushesElm.innerHTML = 'Pushes: ' + ++pushes;
});

addEventListener('keydown', function(e) {
    switch (e.keyCode) {
        case 37:
            eventEmitter.emit('arrowKey.pressed', consts.DIRECTIONS.left);
            break;
        case 38:
            eventEmitter.emit('arrowKey.pressed', consts.DIRECTIONS.up);
            break;
        case 39:
            eventEmitter.emit('arrowKey.pressed', consts.DIRECTIONS.right);
            break;
        case 40:
            eventEmitter.emit('arrowKey.pressed', consts.DIRECTIONS.down);
            break;
    }
});

function gameTick() {
    game.draw();
    window.requestAnimationFrame(gameTick);
}

window.requestAnimationFrame(gameTick);

},{"./Game":1,"./Level":2,"./levels/level0.json":7,"./levels/level1.json":8,"./levels/level2.json":9,"./util/constants":11,"./util/functions":12}],11:[function(require,module,exports){
module.exports = {
    BLOCK_SIZE: 16,
    DIRECTIONS: {
        up: 'up',
        right: 'right',
        down: 'down',
        left: 'left',
        none: 'none'
    }
};

},{}],12:[function(require,module,exports){
var DIRECTIONS = require('./constants').DIRECTIONS;

function getNextPosition(currentPosition, direction) {
    switch (direction) {
        case DIRECTIONS.up: return { x: currentPosition.x, y: currentPosition.y - 1};
        case DIRECTIONS.right: return { x: currentPosition.x + 1, y: currentPosition.y};
        case DIRECTIONS.down: return { x: currentPosition.x, y: currentPosition.y + 1};
        case DIRECTIONS.left: return { x: currentPosition.x - 1, y: currentPosition.y};
        default: return { x: currentPosition.x, y: currentPosition.y };
    }
}

function isSamePosition(pos1, pos2) {
    return pos1.x === pos2.x && pos1.y === pos2.y;
}

function createEventEmitter() {
    var handlers = {};

    return {
        emit: function(event, data) {
            if(handlers[event]) {
                handlers[event].forEach(function(handler) {
                    handler(data);
                });
            }
        },
        on: function(event, handler) {
            if(handler[event]) {
                handlers[event].push(handler);
            } else {
                handlers[event] = [handler];
            }
        }
    };
}

module.exports = {
    getNextPosition: getNextPosition,
    isSamePosition: isSamePosition,
    createEventEmitter: createEventEmitter
};

},{"./constants":11}]},{},[10]);
