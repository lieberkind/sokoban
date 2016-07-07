import { all, contains } from 'ramda'

const Level = {
    mapGrid: grid => grid.map(row => row.split('')),
    isBlock: (grid, position) => grid[position.y][position.x] === '#',
    isWithinMaze: (grid, position) => {
        return position.x < grid[position.y].length &&
            position.x >= 0 &&
            position.y < grid.length &&
            position.y >= 0 &&
            !Level.isBlock(grid, position);
    },
    getGoalFields: grid => {
        let goalFields = []

        grid.forEach((row, y) => {
            row.forEach((field, x) => {
                if (grid[y][x] === 'x') {
                    goalFields.push({x, y});
                }
            })
        })

        return goalFields
    },
    isComplete: (grid, crates) => {
        const goalFields = Level.getGoalFields(grid)

        return all((crate) => {
            return contains(crate, goalFields)
        }, crates);
    }
}

export default Level
