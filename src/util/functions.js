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
