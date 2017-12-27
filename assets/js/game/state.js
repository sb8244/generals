export default class GameState {
  constructor({ board, rows = 0, columns = 0, currentTurn = 0, initialized = false }) {
    this.rows = rows;
    this.columns = columns;
    this.currentTurn = currentTurn;
    this.initialized = initialized;

    if (board) {
      this.board = board;
    } else if (this.rows && this.columns) {
      this.board = Array(this.rows * this.columns).fill(undefined);
    } else {
      this.board = undefined;
    }
  }

  cellAt(r, c) {
    return this.board[r * this.columns + c];
  }

  update(props) {
    const nextState = new GameState(Object.assign({}, this, props));

    if (props.cells && !props.rows) {
      updateCellsInBoard(nextState, props);
    } else if (props.cells && props.rows && props.columns) {
      initializeBoard(nextState, props);
      updateCellsInBoard(nextState, props);
    }

    return nextState;
  }
}

function initializeBoard(state, { rows, columns }) {
  state.board = Array(rows * columns).fill(undefined);
}

function updateCellsInBoard(state, { cells }) {
  const { board } = state;

  cells.forEach((cell) => {
    const { row, column } = cell.coords;
    board[row * state.columns + column] = cell;
  });
}
