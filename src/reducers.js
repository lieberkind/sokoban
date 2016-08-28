import { head } from 'ramda'
import { MOVE, UNDO_MOVE, UNDO_LEVEL, LOAD_LEVEL } from './actions'
import { getNextPosition, isSamePosition } from './util/functions'
import { Level, OBJ_BLOCK, OBJ_CRATE, OBJ_GOAL_FIELD, OBJ_PLAYER } from './services/Level.js'
import Crate from './services/Crate.js'
import { Player, REASON_BLOCK } from './services/Player.js'

// Is this wrong?
// const initialState = {
//     previousState: undefined,
//     levelNumber: undefined,
//     levelCompleted: false,
//     grid: undefined,
//     player: undefined,
//     crates: undefined,
//     movesCount: 0,
//     pushesCount: 0,
//     message: ''
// }

const initialState = {
    past: undefined,
    present: {
        levelNumber: undefined,
        levelCompleted: false,
        grid: undefined,
        player: undefined,
        crates: undefined,
        movesCount: 0,
        pushesCount: 0,
        message: ''
    }
}

// Helper
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
    const { player, grid, crates } = state.present

    const moveResult = Player.canMove(player, grid, crates, direction)

    if (!moveResult.canMove) {
        const newState = Object.assign({}, state.present, {
            message: moveResult.reason === REASON_BLOCK ? 'Ouch!' : '{ooph...grumble}'
        })

        return Object.assign({}, state, {
            past: state.past,
            present: newState
        })
    }

    const nextPlayerPosition = getNextPosition(player, direction)
    const pushedCrate = crates.find(isSamePosition(nextPlayerPosition))
    const newCrates = getNewCrates(crates, pushedCrate, direction)

    const newState = Object.assign({}, state.present, {
        levelCompleted: Level.isComplete(state.present.grid, newCrates),
        player: nextPlayerPosition,
        crates: newCrates,
        movesCount: state.present.movesCount + 1,
        pushesCount: pushedCrate ? state.present.pushesCount + 1 : state.present.pushesCount,
        message: ''
    })

    return Object.assign({}, state, {
        past: state.present,
        present: newState
    })
}

const loadLevel = (state, level) => {
    const mappedGrid = Level.mapGrid(level.grid)

    const newState = Object.assign({}, state.present, {
        levelNumber: level.level,
        levelCompleted: false,
        grid: mappedGrid,
        player: head(Level.getObjectsFromGrid(OBJ_PLAYER, mappedGrid)),
        crates: Level.getObjectsFromGrid(OBJ_CRATE, mappedGrid),
        movesCount: 0,
        pushesCount: 0,
        message: `Playing level ${level.level}...`
    })

    return Object.assign({}, state, {
        past: undefined,
        present: newState
    })
}

const undoMove = state => {
    if (!state.past) {
        return state
    }

    const newState = Object.assign({}, state.past, {
        message: 'Whew! That was close!'
    })

    return Object.assign({}, state, {
        past: undefined,
        present: newState
    })
}

const undoLevel = (state, level) => {
    const newState = Object.assign({}, loadLevel(state, level).present, {
        message: 'Not so easy, is it?'
    });

    return Object.assign({}, state, {
        past: undefined,
        present: newState
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
