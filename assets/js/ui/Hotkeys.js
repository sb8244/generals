import { Component } from 'preact';

const KEYCODE_MOVE_HANDLERS = {
  37: [0, -1], // left
  38: [-1, 0], // up
  39: [0, 1], // right
  40: [1, 0], // down
};

const KEYCODE_HANDLERS = {
  27: (actions) => { // esc
    actions.clearMoveQueue();
    actions.setSelectedCell(undefined);
  },
}

export default class Hotkeys extends Component {
  constructor() {
    super();
    this.onKeyDown = this.onKeyDown.bind(this);
  }

  render() {
    return null;
  }

  componentDidMount() {
    document.addEventListener('keydown', this.onKeyDown)
  }

  componentWillUnmount() {
    document.removeEventListener('keydown', this.onKeyDown);
  }

  onKeyDown(evt) {
    const coordChanges = KEYCODE_MOVE_HANDLERS[evt.keyCode];
    if (coordChanges) {
      if (this.props.gameState.selectedCell) {
        const currentCoords = this.props.gameState.selectedCell.coords;
        const newCoords = { row: currentCoords.row + coordChanges[0], column: currentCoords.column + coordChanges[1] };
        const newCell = this.props.gameState.cellAt(newCoords.row, newCoords.column);
        this.props.setSelectedCell(newCell);
      }
    } else if (KEYCODE_HANDLERS[evt.keyCode]) {
      KEYCODE_HANDLERS[evt.keyCode](this.props);
    }
  }
}
