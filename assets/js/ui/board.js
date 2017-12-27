import { h } from 'preact';

const Board = ({ gameState }) => {
  if (gameState.rows && gameState.columns) {
    return (
      <div className="board">
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
    column.push((
      <div className="board__column">
        { cell ? cell.type.charAt(0) : 'X' }
      </div>
    ));
  }

  return column;
}

export default Board;
