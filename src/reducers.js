import { MOVE, UNDO_MOVE, LOAD_LEVEL } from './actions'
import firstLevel from './levels/level1'
import { getNextPosition, isSamePosition } from './util/functions'
import Level from './Level.js'
import Crate from './Crate.js'
import Player from './Player.js'

const initialState = {}

const getNewCrates = (crates, crate, direction) => {
    if (!crate) {
        return crates;
    }

    const index = crates.indexOf(crate);

    return [
        ...crates.slice(0, index),
        getNextPosition(crate, direction),
        ...crates.slice(index + 1)
    ];   
}

const move = (state, direction) => {
    const { player, grid, crates } = state 

    if (!Player.canMove(player, grid, crates, direction)) {
        return state
    }

    const nextPlayerPosition = getNextPosition(player, direction)
    const pushedCrate = crates.find(isSamePosition(nextPlayerPosition))
    const newCrates = getNewCrates(crates, pushedCrate, direction)

    return Object.assign({}, state, {
        previousState: state,
        levelCompleted: Level.isComplete(state.grid, newCrates),
        player: nextPlayerPosition,
        crates: newCrates,
        movesCount: state.movesCount + 1,
        pushesCount: pushedCrate ? state.pushesCount + 1 : state.pushesCount
    })
}

const loadLevel = (state, level) => {
    return Object.assign({}, state, {
        previousState: undefined,
        levelNumber: level.level,
        levelCompleted: false,
        grid: Level.mapGrid(level.grid),
        player: level.player,
        crates: level.crates,
        movesCount: 0,
        pushesCount: 0
    })
}

const sokoban = function(state = initialState, action) {
    switch (action.type) {
        case MOVE:
            return move(state, action.direction)
        case LOAD_LEVEL:
            return loadLevel(state, action.level)
        default:
            return state
    }
}

export default sokoban
