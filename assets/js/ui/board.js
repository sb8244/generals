import { h } from 'preact';

const Board = ({ gameState, position, setSelectedCoords }) => {
  if (gameState.rows && gameState.columns) {
    return (
      <div className="board" style={position}>
        { getRows(gameState, setSelectedCoords) }
      </div>
    );
  } else {
    return <div>Loading...</div>;
  }
};

function getRows(gameState, setSelectedCoords) {
  const rows = [];

  for (let r = 0; r < gameState.rows; r++) {
    rows.push((
      <div className="board__row">
        { getColumn(gameState, r, setSelectedCoords) }
      </div>
    ));
  }

  return rows;
}

function getColumn(gameState, row, setSelectedCoords) {
  const column = [];

  for (let c = 0; c < gameState.columns; c++) {
    const cell = gameState.cellAt(row, c);
    const classes = [];

    if (!cell || !cell.visible) {
      classes.push('board__column--fog');
    } else {
      classes.push('board__column--visible');
    }

    if (cell && coordsEqual(cell.coords, gameState.selectedCoords)) {
      classes.push('board__column--selected');
    }

    column.push((
      <div className={`board__column ${classes.join(' ')}`} onClick={cellClick(gameState, cell, setSelectedCoords)}>
        { cell ? cell.type.charAt(0) : '' }
      </div>
    ));
  }

  return column;
}

function cellClick(gameState, cell, setSelectedCoords) {
  return (evt) => {
    if (coordsEqual(cell.coords, gameState.selectedCoords)) {
      setSelectedCoords(undefined);
    } else {
      setSelectedCoords(cell.coords);
    }
  };
}

function coordsEqual(coords, coords2) {
  return coords && coords2 && coords.row === coords2.row && coords.column === coords2.column;
}

export default Board;
