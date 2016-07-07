import { getNextPosition, isSamePosition } from './util/functions'
import Level from './Level'
import Crate from './Crate'

const Player = {
    canMove: (player, grid, crates, direction) => {
        const dPosition = getNextPosition(player, direction);

        const collidingCrate = crates.find(crate => isSamePosition(crate, dPosition))

        const isWithinMaze = Level.isWithinMaze(grid, dPosition);

        return collidingCrate
            ? isWithinMaze && Crate.canMove(collidingCrate, grid, crates, direction)
            : isWithinMaze;
    }
}

export default Player
