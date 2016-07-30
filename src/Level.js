import { all, contains } from 'ramda'

export const OBJ_BLOCK = '#'
export const OBJ_CRATE = 'c'
export const OBJ_PLAYER = 'p'
export const OBJ_GOAL_FIELD = 'x'

export const Level = {
    mapGrid: grid => grid.map(row => row.split('')),
    isBlock: (grid, position) => grid[position.y][position.x] === OBJ_BLOCK,
    isWithinMaze: (grid, position) => {
        return position.x < grid[position.y].length &&
            position.x >= 0 &&
            position.y < grid.length &&
            position.y >= 0 &&
            !Level.isBlock(grid, position);
    },
    getObjectsFromGrid: (objectType, grid) => {
        let objects = []

        grid.forEach((row, y) => {
            row.forEach((object, x) => {
                if (grid[y][x] === objectType) {
                    objects.push({x, y});
                }
            })
        })

        return objects
    },
    isComplete: (grid, crates) => {
        const goalFields = Level.getObjectsFromGrid(OBJ_GOAL_FIELD, grid)

        return all((crate) => {
            return contains(crate, goalFields)
        }, crates);
    }
}
