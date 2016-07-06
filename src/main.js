import 'babel-polyfill'
import { curry } from 'ramda'
import { createStore } from 'redux'
import * as actions from './actions'
import sokoban from './reducers'

let store = createStore(sokoban);

const BLOCK_SIZE = 16;

// Get Context
var canvas = document.getElementById('game');
canvas.width = 608;
canvas.height = 544;
var context = canvas.getContext('2d');
context.scale(2, 2);


let blockSprite = new Image;
blockSprite.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAaklEQVRYR+3XOQ7AIAxE0XD/4yQVS8HJjIRkCqdIBVPkUyMYP7mZZGZ2Cc5T2/w1/S6AT95z1wh8BvALu9bCJ/f3XztAAAQQQAABBBBAAAEEEJAJxMKwqxfEd1cvkAW4S53tODaWYwLqAAMAoAJYuhkgzQAAAABJRU5ErkJgggAA';

let goalFieldSprite = new Image;
goalFieldSprite.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAYklEQVRYR+3VywoAIAhEUf3/jzYi2rjTgR5w3UvjIdTNLOxiOQEQQAABBL4ViFgnxH1u8361b8EzAfLsVRFZ4HiATa8+vPvLAtcD5MnVz1gWeC5AfwOsTlmAAAgggAACqsAA1gU4AQHGir0AAAAASUVORK5CYIIA';

let crateSprite = new Image;
crateSprite.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAwklEQVRYR+2W2w2AIAwAYThmUSdSZ2E4jMQmyFtsLTH4SaS9XqBFCuZPMucXNQCGCNLm7hrAVr4KhSJgEdqPUzTABkCSWO2bNaCnGUwkDbABkJx2qBzKzhnoA8AgYcjrgj820C8AtKxKQ/gG2ABSzbpgAs8AG0DNmDovd8LEewPsALeOHRmI/z8Dw8AwgGzAfwfEwtuLFUxDpE7YDtD4JoZO6GyPluIuxg18DdCYL7ct29QDA5wABLnLIWtnXjlS4x8HfjeSIYxtab0AAAAASUVORK5CYIIA';

var sokoSprite = new Image;        
sokoSprite.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA70lEQVRYR+2XURKAIAhE9f6HtqnJmUJWWCPto/4ygscGmDmNXwW8mhmXlLFw/A5AKelwnHNCcMdzGV0xvi0hv817XwZQM5ffGykRocBcgKaS2XIFJSprC9bAMoBL4JvkkrQmiNarH6s7esIuA+j2eRGp1wzkurc7NAWWAbjajJnzmq3M+Hq/DGBKYFQTuwI/wHIF6ufx7vNUI1j/DWYXsHuQpGMAukpQaSvGaE9wT8KZAKFKhO2Gowo8AXikhBW487/Q5Do0JyIBKCW8gRkFPgPATkzXDHMZaWdCa8LtpztP57iMgKN3Dqce6tMmBGAD3QtmGY9VnUMAAAAASUVORK5CYIIA';

const drawElement = curry((context, sprite, x, y) => {
    var startX = x * BLOCK_SIZE;
    var startY = y * BLOCK_SIZE;

    context.drawImage(sprite, startX, startY, BLOCK_SIZE, BLOCK_SIZE);    
})(context);

const draw = function(context, state) {
    context.clearRect(0, 0, context.canvas.width, context.canvas.height);

    const { grid, player, crates } = state;

    // draw the maze
    grid.forEach(function(row, y) {
        row.forEach(function(field, x) {
            switch (grid[y][x]) {
                case '#': 
                    drawElement(blockSprite, x, y);
                    break;
                case 'x':
                    drawElement(goalFieldSprite, x, y);
                    break;
                default: break;
            }
        });
    });

    // draw the crates
    crates.forEach(function(crate) {
        drawElement(crateSprite, crate.x, crate.y);
    });

    // draw the player
    drawElement(sokoSprite, player.x, player.y);
};

var unsubscribe = store.subscribe(function() {
    const state = store.getState()

    // Draw the game
    draw(context, state)

    document.querySelector('[moves]').innerHTML = `${state.movesCount} moves`
    document.querySelector('[pushes]').innerHTML = `${state.pushesCount} moves`

    if(state.levelCompleted) {
        alert(`Level completed with ${state.movesCount} moves and ${state.pushesCount} pushes`);
    }
});

// TODO: figure out how to start the game...
store.dispatch({ type: 'UNDO_MOVE' });

addEventListener('keydown', function(e) {
    switch (e.keyCode) {
        case 37:
            store.dispatch(actions.move('left'))
            break;
        case 38:
            store.dispatch(actions.move('up'))
            break;
        case 39:
            store.dispatch(actions.move('right'))
            break;
        case 40:
            store.dispatch(actions.move('down'))
            break;
    }
});
