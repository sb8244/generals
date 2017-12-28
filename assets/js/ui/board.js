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

    if (!cell.visible) {
      classes.push('board__column--fog');
    } else {
      classes.push('board__column--visible');
    }

    if (gameState.selectedCell && coordsEqual(cell.coords, gameState.selectedCell.coords)) {
      classes.push('board__column--selected');
    }

    column.push((
      <div className={`board__column ${classes.join(' ')}`} onClick={cellClick(gameState, cell, setSelectedCoords)}>
        <span>{ cell.type.charAt(0) }</span>
        { cell && cell.population_count ? <span>{cell.population_count}</span> : '' }
      </div>
    ));
  }

  return column;
}

function cellClick(gameState, cell, setSelectedCoords) {
  return (evt) => {
    if (gameState.selectedCell && coordsEqual(cell.coords, gameState.selectedCell.coords)) {
      setSelectedCoords(undefined);
    } else {
      setSelectedCoords(cell);
    }
  };
}

function coordsEqual(coords, coords2) {
  return coords && coords2 && coords.row === coords2.row && coords.column === coords2.column;
}

export default Board;
