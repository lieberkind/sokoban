import { getNextPosition } from './util/functions'
import Level from './Level'

const Crate = {
    canMove: (crate, grid, crates, direction) => {
        var dPosition = getNextPosition(crate, direction);

        var crateIsBlocking = crates.some(function(crate) {
            return crate.x === dPosition.x && crate.y === dPosition.y
        });

        return Level.isWithinMaze(grid, dPosition) && !crateIsBlocking;
    }
}

export default Crate
