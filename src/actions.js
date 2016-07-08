export const MOVE = 'MOVE';
export const UNDO_MOVE = 'UNDO_MOVE';
export const UNDO_LEVEL = 'UNDO_LEVEL';
export const LOAD_LEVEL = 'LOAD_LEVEL';

export const move = (direction) => ({ type: MOVE, direction })
export const undoMove = () => ({ type: UNDO_MOVE })
export const undoLevel = (level) => ({ type: UNDO_LEVEL, level })
export const loadLevel = (level) => ({ type: LOAD_LEVEL, level })
