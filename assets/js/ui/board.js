import { h } from 'preact';

const Board = ({ gameState, position }) => {
  if (gameState.rows && gameState.columns) {
    return (
      <div className="board" style={position}>
        { getRows(gameState) }
      </div>
    );
  } else {
    return <div>Loading...</div>;
  }
};

function getRows(gameState) {
  const rows = [];

  for (let r = 0; r < gameState.rows; r++) {
    rows.push((
      <div className="board__row">
        { getColumn(gameState, r) }
      </div>
    ));
  }

  return rows;
}

function getColumn(gameState, row) {
  const column = [];

  for (let c = 0; c < gameState.columns; c++) {
    const cell = gameState.cellAt(row, c);
    const classes = [];

    if (!cell || !cell.visible) {
      classes.push('board__column--fog');
    } else {
      classes.push('board__column--visible');
    }

    column.push((
      <div className={`board__column ${classes.join(' ')}`} onClick={cellClick(cell)}>
        { cell ? cell.type.charAt(0) : '' }
      </div>
    ));
  }

  return column;
}

function cellClick(cell) {
  return (evt) => {
    console.log('click', cell);
  };
}

export default Board;
