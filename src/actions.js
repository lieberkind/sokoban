export const MOVE = 'MOVE';
export const UNDO_MOVE = 'UNDO_MOVE';
export const UNDO_LEVEL = 'UNDO_LEVEL';
export const SOKO_SPRITE_CHANGED = 'SOKO_SPRITE_CHANGED';

export const Directions = {
    LEFT: 'LEFT',
    RIGHT: 'RIGHT',
    UP: 'UP',
    DOWN: 'DOWN'
};

export const changeSokoSprite = (nextSprite) => ({ type: SOKO_SPRITE_CHANGED, nextSprite })
export const move = (direction) => ({ type: MOVE, direction })
export const undoMove = () => ({ type: UNDO_MOVE })
export const undoLevel = () => ({ type: UNDO_LEVEL })
