import * as actions from './actions'
import firstLevel from './levels/level1'
import { getNextPosition, isSamePosition } from './util/functions'

const Level = {
    mapGrid: grid => grid.map(row => row.split('')),
    isBlock: (grid, position) => grid[position.y][position.x] === '#',
    isWithinMaze: (grid, position) => {
        return position.x < grid[position.y].length &&
            position.x >= 0 &&
            position.y < grid.length &&
            position.y >= 0 &&
            !Level.isBlock(grid, position);
    }
}

const initialState = {
    previousState: undefined,
    levelNumber: firstLevel.level,
    levelCompleted: false,
    grid: Level.mapGrid(firstLevel.grid),
    player: firstLevel.player,
    crates: firstLevel.crates,
    movesCount: 0,
    pushesCount: 0
}

const Crate = {
    canMove: (crate, grid, crates, direction) => {
        var dPosition = getNextPosition(crate, direction);

        var crateIsBlocking = crates.some(function(crate) {
            return crate.x === dPosition.x && crate.y === dPosition.y
        });

        return Level.isWithinMaze(grid, dPosition) && !crateIsBlocking;
    }
}

const Player = {
    canMove: (player, grid, crates, direction) => {
        const dPosition = getNextPosition(player, direction);

        const collidingCrate = crates.find(crate => isSamePosition(crate, dPosition))

        const isWithinMaze = Level.isWithinMaze(grid, dPosition);

        return collidingCrate
            ? isWithinMaze && Crate.canMove(collidingCrate, direction)
            : isWithinMaze;
    }
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
        player: nextPlayerPosition,
        crates: newCrates,
        movesCount: state.movesCount + 1,
        pushesCount: crate ? state.pushesCount + 1 : state.pushesCount
    })
}

export const sokoban = function(state = initialState, action) {
    switch (action.type) {
        case actions.MOVE:
            return makeMove(state, action.direction)
        default:
            return state
    }
}
