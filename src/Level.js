function Level(level) {
    this.grid = level.grid.map(function(row) {
        return row.split("");
    });
    this.crates = level.crates;
    this.player = level.player;
}

Level.prototype.isBlock = function(position) {
    return this.grid[position.y][position.x] === '#';
};

Level.prototype.isGoalField = function(position) {
    return this.grid[position.y][position.x] === 'x';
}

Level.prototype.isWithinMaze = function(position) {
    return position.x < this.grid[position.y].length &&
        position.x >= 0 &&
        position.y < this.grid.length &&
        position.y >= 0 &&
        !this.isBlock(position);
};

module.exports = Level;
