import { MOVE, UNDO_MOVE } from './actions'
import firstLevel from './levels/level1'
import { getNextPosition, isSamePosition } from './util/functions'
import Level from './Level.js'
import Crate from './Crate.js'
import Player from './Player.js'

const initialState = {
    sokoSprite: 0,
    previousState: undefined,
    levelNumber: firstLevel.level,
    levelCompleted: false,
    grid: Level.mapGrid(firstLevel.grid),
    player: firstLevel.player,
    crates: firstLevel.crates,
    movesCount: 0,
    pushesCount: 0
}

const makeMove = (state, direction) => {
    const { player, grid, crates } = state 

    if (!Player.canMove(player, grid, crates, direction)) {
        return state
    }

    const nextPlayerPosition = getNextPosition(player, direction)

    const crate = crates.find(crate => isSamePosition(nextPlayerPosition, crate))

    const newCrates = (function() {
        if (!crate) {
            return crates;
        }

        const index = crates.indexOf(crate);

        return [
            ...crates.slice(0, index),
            getNextPosition(crate, direction),
            ...crates.slice(index + 1)
        ];
    }());

    return Object.assign({}, state, {
        previousState: state,
        levelCompleted: Level.isComplete(state.grid, newCrates),
        player: nextPlayerPosition,
        crates: newCrates,
        movesCount: state.movesCount + 1,
        pushesCount: crate ? state.pushesCount + 1 : state.pushesCount
    })
}

const sokoban = function(state = initialState, action) {
    switch (action.type) {
        case MOVE:
            return makeMove(state, action.direction)
        default:
            return state
    }
}

export default sokoban
