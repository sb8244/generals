import Cell, { NullCell } from './cell';

export default class GameState {
  constructor({ board, rows = 0, columns = 0, currentTurn = 0, initialized = false, selectedCell }) {
    this.rows = rows;
    this.columns = columns;
    this.currentTurn = currentTurn;
    this.initialized = initialized;
    this.selectedCell = selectedCell;

    if (board) {
      this.board = board;
    } else if (this.rows && this.columns) {
      this.board = Array(this.rows * this.columns).fill(undefined);
    } else {
      this.board = undefined;
    }
  }

  cellAt(r, c) {
    const cell = this.board[r * this.columns + c];

    if (cell) {
      return cell;
    } else {
      return new NullCell({ row: r, column: c });
    }
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
    const index = row * state.columns + column;

    if (cell.type === 'mountain' && board[index] && board[index].visible) {
      cell.visible = true;
    }

    board[index] = new Cell(cell);
  });
}
