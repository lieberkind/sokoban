var consts = require('./util/constants');
var helpers = require('./util/functions');
var Game = require('./Game');
var Level = require('./Level');
var R = require('ramda');

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
            var nextLevelIdx = game.getCurrentLevel().getLevelNumber() + 1;

            if(nextLevelIdx === LEVELS.length) {
                alert('Congratulations, you have won the game!');
            } else {
                alert('Kneeep');
                var nextLevel = LEVELS[nextLevelIdx];
                game.loadLevel(new Level(LEVELS[nextLevelIdx]));
            }
        });
    });
});

var moves = 0;
eventEmitter.on('player.moved', function() {
    var movesElm = document.querySelector('[moves]');
    movesElm.innerHTML = (++moves) + ' moves';
});

var pushes = 0;
eventEmitter.on('crate.moved', function() {
    var pushesElm = document.querySelector('[pushes]');
    pushesElm.innerHTML = (++pushes) + ' pushes';
});

var movesList = [];

addEventListener('keydown', function(e) {
    switch (e.keyCode) {
        case 37:
            eventEmitter.emit('arrowKey.pressed', consts.DIRECTIONS.left);
            movesList = R.append(consts.DIRECTIONS.left, movesList);
            break;
        case 38:
            eventEmitter.emit('arrowKey.pressed', consts.DIRECTIONS.up);
            movesList = R.append(consts.DIRECTIONS.up, movesList);
            break;
        case 39:
            eventEmitter.emit('arrowKey.pressed', consts.DIRECTIONS.right);
            movesList = R.append(consts.DIRECTIONS.right, movesList);
            break;
        case 40:
            eventEmitter.emit('arrowKey.pressed', consts.DIRECTIONS.down);
            movesList = R.append(consts.DIRECTIONS.down, movesList);
            break;
    }

    console.log(movesList);
});

function gameTick() {
    game.draw();
    window.requestAnimationFrame(gameTick);
}

window.requestAnimationFrame(gameTick);
