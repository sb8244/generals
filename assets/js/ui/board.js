import { h } from 'preact';

const Board = ({ gameState, position, setSelectedCell }) => {
  if (gameState.rows && gameState.columns) {
    return (
      <div className="board" style={position}>
        { getRows(gameState, setSelectedCell) }
      </div>
    );
  } else {
    return <div>Loading...</div>;
  }
};

function getRows(gameState, setSelectedCell) {
  const rows = [];

  for (let r = 0; r < gameState.rows; r++) {
    rows.push((
      <div className="board__row">
        { getColumn(gameState, r, setSelectedCell) }
      </div>
    ));
  }

  return rows;
}

function getColumn(gameState, row, setSelectedCell) {
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
      <div className={`board__column ${classes.join(' ')}`} onClick={cellClick(gameState, cell, setSelectedCell)}>
        <span>{ cell.displayChar() }</span>
        { cell && cell.population_count ? <span>{cell.population_count}</span> : '' }
      </div>
    ));
  }

  return column;
}

function cellClick(gameState, cell, setSelectedCell) {
  return (evt) => {
    if (gameState.selectedCell && coordsEqual(cell.coords, gameState.selectedCell.coords)) {
      setSelectedCell(undefined);
    } else {
      setSelectedCell(cell);
    }
  };
}

function coordsEqual(coords, coords2) {
  return coords && coords2 && coords.row === coords2.row && coords.column === coords2.column;
}

export default Board;
