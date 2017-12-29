export default class Move {
  constructor({from, to, queueMove}) {
    this.from = from;
    this.to = to;
    this.queueMove = queueMove;
  }

  move() {
    if (!this.from || !this.to) { return false; }

    if (this.coordsNextToEachOther()) {
      this.queueMove(this.from.coords, this.to.coords);
      return true;
    }

    return false;
  }

  coordsNextToEachOther() {
    return this.from.manhattanDistance(this.to) === 1;
  }
}
