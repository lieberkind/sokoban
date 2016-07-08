import { MOVE, UNDO_MOVE, UNDO_LEVEL, LOAD_LEVEL } from './actions'
import { getNextPosition, isSamePosition } from './util/functions'
import Level from './Level.js'
import Crate from './Crate.js'
import { Player, REASON_BLOCK } from './Player.js'

// Is this wrong?
const initialState = {
    previousState: undefined,
    levelNumber: undefined,
    levelCompleted: false,
    grid: undefined,
    player: undefined,
    crates: undefined,
    movesCount: 0,
    pushesCount: 0,
    message: ''
}

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

    const moveResult = Player.canMove(player, grid, crates, direction)

    if (!moveResult.canMove) {
        return Object.assign({}, state, {
            message: moveResult.reason === REASON_BLOCK ? 'Ouch!' : '{ooph...grumble}'
        })
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
        pushesCount: pushedCrate ? state.pushesCount + 1 : state.pushesCount,
        message: ''
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
        pushesCount: 0,
        message: `Playing level ${level.level}...`
    })
}

const undoMove = state => {
    if (!state.previousState) {
        return state
    }

    return Object.assign({}, state.previousState, {
        previousState: undefined,
        message: 'Whew! That was close!'
    })
}

const undoLevel = (state, level) => {
    return Object.assign({}, loadLevel(state, level), {
        message: 'Not so easy, is it?'
    })
}

const sokoban = function(state = initialState, action) {
    switch (action.type) {
        case MOVE: return move(state, action.direction)
        case LOAD_LEVEL: return loadLevel(state, action.level)
        case UNDO_MOVE: return undoMove(state)
        case UNDO_LEVEL: return undoLevel(state, action.level)
        default: return state
    }
}

export default sokoban
