export default class Cell {
  constructor(json) {
    Object.assign(this, json);
  }

  manhattanDistance(cell) {
    return Math.abs(this.coords.row - cell.coords.row) + Math.abs(this.coords.column - cell.coords.column);
  }
}

export class NullCell extends Cell {
  constructor({ row, column }) {
    super({
      type: '',
      coords: {
        row,
        column,
      },
    });
  }
}
