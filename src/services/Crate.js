import { getNextPosition, isSamePosition } from '../util/functions'
import { Level } from './Level'

const Crate = {
    canMove: (crate, grid, crates, direction) => {
        const dPosition = getNextPosition(crate, direction);

        const crateIsBlocking = crates.some(isSamePosition(dPosition));

        return Level.isWithinMaze(grid, dPosition) && !crateIsBlocking;
    },
    getNewCrates: (crates, crate, direction) => {
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
}

export default Crate
