import * as SPRITES from './sprites'

const BLOCK_SIZE = 16;

let sokoSpriteIndex = 0;

const paintElement = (context, sprite, x, y) => {
    var startX = x * BLOCK_SIZE;
    var startY = y * BLOCK_SIZE;

    context.drawImage(sprite, startX, startY, BLOCK_SIZE, BLOCK_SIZE);    
};

export const paint = (context, state) => {
    context.clearRect(0, 0, context.canvas.width, context.canvas.height);

    const { grid, player, crates } = state;

    // draw the maze
    grid.forEach(function(row, y) {
        row.forEach(function(field, x) {
            switch (grid[y][x]) {
                case '#': 
                    paintElement(context, SPRITES.BLOCK, x, y);
                    break;
                case 'x':
                    paintElement(context, SPRITES.GOAL_FIELD, x, y);
                    break;
                default: break;
            }
        });
    });

    // draw the crates
    crates.forEach(function(crate) {
        paintElement(context, SPRITES.CRATE, crate.x, crate.y);
    });

    // draw the player
    paintElement(context, SPRITES.SOKO[sokoSpriteIndex], player.x, player.y);
};

export const resetSoko = () => {
    sokoSpriteIndex = 0
}

export const paintNextSoko = (context, state) => {
    sokoSpriteIndex = (sokoSpriteIndex + 1) % 6
    paint(context, state)
}
