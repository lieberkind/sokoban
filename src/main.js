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
