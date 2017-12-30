export default class Cell {
  constructor(json) {
    Object.assign(this, json);
  }

  manhattanDistance(cell) {
    return Math.abs(this.coords.row - cell.coords.row) + Math.abs(this.coords.column - cell.coords.column);
  }

  displayChar() {
    if (this.type === 'plains') {
      return '';
    } else {
      return this.type.charAt(0);
    }
  }

  clickable() {
    return this.owner === 0;
  }

  isMovable() {
    return this.type !== 'mountain';
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
