import { head } from 'ramda'
import { MOVE, UNDO_MOVE, UNDO_LEVEL, LOAD_LEVEL } from './actions'
import { getNextPosition, isSamePosition } from './util/functions'
import { Level, OBJ_BLOCK, OBJ_CRATE, OBJ_GOAL_FIELD, OBJ_PLAYER } from './services/Level.js'
import Crate from './services/Crate.js'
import { Player, REASON_BLOCK } from './services/Player.js'

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
    const newCrates = Crate.getNewCrates(crates, pushedCrate, direction)

    const previousState = Object.assign({}, state, {
        previousState: undefined
    })

    return Object.assign({}, state, {
        previousState: previousState,
        levelCompleted: Level.isComplete(state.grid, newCrates),
        player: nextPlayerPosition,
        crates: newCrates,
        movesCount: state.movesCount + 1,
        pushesCount: pushedCrate ? state.pushesCount + 1 : state.pushesCount,
        message: ''
    })
}

const loadLevel = (state, level) => {
    const mappedGrid = Level.mapGrid(level.grid)

    return Object.assign({}, state, {
        previousState: undefined,
        levelNumber: level.level,
        levelCompleted: false,
        grid: mappedGrid,
        player: head(Level.getObjectsFromGrid(OBJ_PLAYER, mappedGrid)),
        crates: Level.getObjectsFromGrid(OBJ_CRATE, mappedGrid),
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
