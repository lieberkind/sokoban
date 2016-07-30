import { getNextPosition, isSamePosition } from './util/functions'
import { Level } from './Level'

const Crate = {
    canMove: (crate, grid, crates, direction) => {
        const dPosition = getNextPosition(crate, direction);

        const crateIsBlocking = crates.some(isSamePosition(dPosition));

        return Level.isWithinMaze(grid, dPosition) && !crateIsBlocking;
    }
}

export default Crate
