export const MOVE = 'MOVE';
export const UNDO_MOVE = 'UNDO_MOVE';
export const UNDO_LEVEL = 'UNDO_LEVEL';

export const Directions = {
    LEFT: 'LEFT',
    RIGHT: 'RIGHT',
    UP: 'UP',
    DOWN: 'DOWN'
};

export const move = direction => { type: MOVE, direction }
export const undoMove = () => { type: UNDO_MOVE }
export const undoLevel = () => { type: UNDO_LEVEL }
