import { getNextPosition, isSamePosition } from '../util/functions'
import { Level } from './Level'
import Crate from './Crate'

export const REASON_BLOCK = 'BLOCK'
export const REASON_CRATE = 'CRATE'

const createMoveResult = (canMove, reason) => {
    return {
        canMove,
        reason: canMove ? undefined : reason
    }
}

export const Player = {
    canMove: (player, grid, crates, direction) => {
        const dPosition = getNextPosition(player, direction);

        const collidingCrate = crates.find(isSamePosition(dPosition))

        return collidingCrate
            ? createMoveResult(Crate.canMove(collidingCrate, grid, crates, direction), REASON_CRATE)
            : createMoveResult(Level.isWithinMaze(grid, dPosition), REASON_BLOCK)
    }
}
