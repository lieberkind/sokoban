import 'babel-polyfill'
import { curry } from 'ramda'
import { createStore } from 'redux'
import * as actions from './actions'
import sokoban from './reducers'
import level0 from './levels/0'
import level1 from './levels/1'
import level2 from './levels/2'

let store = createStore(sokoban);

const LEVELS = [level0, level1, level2]
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

let sokoSprite = new Image;
sokoSprite.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA70lEQVRYR+2XURKAIAhE9f6HtqnJmUJWWCPto/4ygscGmDmNXwW8mhmXlLFw/A5AKelwnHNCcMdzGV0xvi0hv817XwZQM5ffGykRocBcgKaS2XIFJSprC9bAMoBL4JvkkrQmiNarH6s7esIuA+j2eRGp1wzkurc7NAWWAbjajJnzmq3M+Hq/DGBKYFQTuwI/wHIF6ufx7vNUI1j/DWYXsHuQpGMAukpQaSvGaE9wT8KZAKFKhO2Gowo8AXikhBW487/Q5Do0JyIBKCW8gRkFPgPATkzXDHMZaWdCa8LtpztP57iMgKN3Dqce6tMmBGAD3QtmGY9VnUMAAAAASUVORK5CYIIA';

let sokoSprite1 = new Image;        
sokoSprite1.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA70lEQVRYR+2XURKAIAhE9f6HtqnJmUJWWCPto/4ygscGmDmNXwW8mhmXlLFw/A5AKelwnHNCcMdzGV0xvi0hv817XwZQM5ffGykRocBcgKaS2XIFJSprC9bAMoBL4JvkkrQmiNarH6s7esIuA+j2eRGp1wzkurc7NAWWAbjajJnzmq3M+Hq/DGBKYFQTuwI/wHIF6ufx7vNUI1j/DWYXsHuQpGMAukpQaSvGaE9wT8KZAKFKhO2Gowo8AXikhBW487/Q5Do0JyIBKCW8gRkFPgPATkzXDHMZaWdCa8LtpztP57iMgKN3Dqce6tMmBGAD3QtmGY9VnUMAAAAASUVORK5CYIIA';

let sokoSprite2 = new Image;
sokoSprite2.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA90lEQVRYR+2XwRLDIAhE9f8/2kyZaFsE2U1i9dDcYlAf64KTnK4/xZmamSWpYLXwXIBSkmyQc9KQMq53NzKRocE6ko+rwI4AZub6vDu5TqkMJWkF1gC0DFm7KpNcVmAZQDV65Pb63SwV2+VfoSNhoXKbATA229vVcjpNIW/8PEOvT1gKLAOAyozp81aszvjzfRnATzb2OuZLgT/AcgXq8UCNh62CqJOGVcDeQRqQARgq0WVe+utupM5znbBhzgPglAhM4WVep9G3IWvCOwC3lIg2RhTYBoACQTNnFNgGgO2YUA+DgpTz0ZYNrQ0FOaU39+cUqPdHAA6h4GgZpdYA/gAAAABJRU5ErkJgggAA';

let sokoSprite3 = new Image;
sokoSprite3.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA/ElEQVRYR+2X4Q7DIAiE5f0f2qWNNB3l5DA6t2T908QifD0QVcr4U8FUybhMGRvHawBqLadjkYLgzu82umP8NoT8PuZ9M4D75zbfSIkZCnwW4FHJ2XIFJWprC9bANoBbYEryaM1Hq6Mn7DaAfuCWW2noV6rReJMIKeEpsA2AktwSqwJoPOoT93nbAKjAUbVnv+ufH+8/wHYFNH3sPp9Kd3RuCFdBdg+ydBmArhKX44pOYtryfOSJnXA9wJgSujmYHKzbDW0qFgBwSvCXA7c4mCIf6hOR9MrNAKSUYAP/JEC2Y1LqUkbenTDqcMftjunZlBFwtOZyylA3mykALw46bhmB1MFZAAAAAElFTkSuQmCC';

let sokoSprite4 = new Image;
sokoSprite4.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAABB0lEQVRYR9WW2w7EIAhE5f8/2k3d2ChyGUzVdl82aZUehgGlNP/LylaKhAwtZoHXAOScSmCipMGV9/zrwuLukRZ32PdmADFzXm9NiScU2AswODlqV8Wi3FuqB44BNB/uJJ8VwOsOK+4xALvPa205OnuOzglJgWMAZpvNesCbE23cYwDQgImccMjamvn1/w2ApzxQ1QkrsBKgQkHnfM7aPeQfhqhH9eaB2wXDvFkIAClh55/ua5SX+SVWUUxoGbMUOwAwJVgpau3RzHk3SLPDVmIDAKREt6hJw7sHIAq8BsAE8U47xej3tsiAg84MVPpICXiS0MT0Mv80gGb8qaQiHhBLIQyQUMwfGRx6GRgbXCgAAAAASUVORK5CYIIA';

let sokoSprites = [sokoSprite1, sokoSprite2, sokoSprite3, sokoSprite4, sokoSprite3, sokoSprite2];
let sokoSpriteIndex = 0;

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
    drawElement(sokoSprites[sokoSpriteIndex], player.x, player.y);
};

const loadLevel = (context, level) => {
    store.dispatch(actions.loadLevel(level));

    return setInterval(function() {
        var isLastSprite = sokoSpriteIndex === sokoSprites.length - 1;
        sokoSpriteIndex = isLastSprite ? 0 : sokoSpriteIndex + 1;

        draw(context, store.getState());
    }, 300);    
}

var unsubscribe = store.subscribe(function() {
    const state = store.getState()

    // Draw the game
    draw(context, state)

    document.querySelector('[moves]').innerHTML = `${state.movesCount} moves`
    document.querySelector('[pushes]').innerHTML = `${state.pushesCount} moves`
    document.querySelector('[message]').innerHTML = `${state.message}`

    if(state.levelCompleted) {
        alert(`Level ${state.levelNumber} completed with ${state.movesCount} moves and ${state.pushesCount} pushes`);

        store.dispatch(actions.loadLevel(LEVELS[state.levelNumber + 1]))
    }
});

store.dispatch(actions.loadLevel(LEVELS[0]));

document.getElementById('undo-move').addEventListener('click', () => {
    store.dispatch(actions.undoMove())
})

document.getElementById('undo-level').addEventListener('click', () => {
    const levelNumber = store.getState().levelNumber
    store.dispatch(actions.loadLevel(LEVELS[levelNumber]))
})

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
