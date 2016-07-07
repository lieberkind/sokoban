import { curry } from 'ramda'
var DIRECTIONS = require('./constants').DIRECTIONS;

export const getNextPosition = (currentPosition, direction) => {
    switch (direction) {
        case DIRECTIONS.up: return { x: currentPosition.x, y: currentPosition.y - 1};
        case DIRECTIONS.right: return { x: currentPosition.x + 1, y: currentPosition.y};
        case DIRECTIONS.down: return { x: currentPosition.x, y: currentPosition.y + 1};
        case DIRECTIONS.left: return { x: currentPosition.x - 1, y: currentPosition.y};
        default: return { x: currentPosition.x, y: currentPosition.y };
    }
}

export const isSamePosition = curry((pos1, pos2) => {
    return pos1.x === pos2.x && pos1.y === pos2.y;
})
