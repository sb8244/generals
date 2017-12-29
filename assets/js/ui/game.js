import { h, Component } from 'preact';

import connectSocket from '../socket';
import GameState from '../game/state';
import Move from '../game/move';

import Board from './Board';
import GameScroll from './GameScroll';
import Hotkeys from './Hotkeys';

export default class Game extends Component {
  constructor(props) {
    super(props);
    this.state = {
      gameState: new GameState({}),
      boardPosition: {
        top: 0,
        left: 0,
      },
    };

    this.setupSocket(props);
    this.changeBoardPosition = this.changeBoardPosition.bind(this);
    this.setSelectedCell = this.setSelectedCell.bind(this);
    this.queueMove = this.queueMove.bind(this);
  }

  changeBoardPosition({ horizontal, vertical }) {
    const { top, left } = this.state.boardPosition;
    this.setState({
      boardPosition: {
        top: top + vertical,
        left: left + horizontal,
      },
    });
  }

  render() {
    const { children } = this.props;
    const { gameState, boardPosition } = this.state;

    return (
      <div className="board__wrapper">
        <GameScroll changeBoardPosition={this.changeBoardPosition} />
        <Hotkeys gameState={gameState} setSelectedCell={this.setSelectedCell} />
        <Board gameState={gameState} position={boardPosition} setSelectedCell={this.setSelectedCell} />
      </div>
    )
  }

  queueMove(from, to) {
    if (this.channel) {
      this.channel.push("queue_move", { token: gameAuthToken, from, to }).receive("ok", (payload) => {
        console.log(payload);
      }).receive("error", (resp) => {
        console.log("error", resp);
      });
    }
  }

  setSelectedCell(cell) {
    if (!cell) {
      this.setState({
        gameState: this.state.gameState.update({ selectedCell: undefined }),
      });

      return;
    }

    let moved = false;
    const fromCell = this.state.gameState.selectedCell;

    if (cell.isMovable() && fromCell) {
      const move = new Move({
        from: fromCell,
        to: cell,
        queueMove: this.queueMove,
      });
      moved = move.move();
    }

    if (cell.clickable() || moved) {
      this.setState({
        gameState: this.state.gameState.update({ selectedCell: cell }),
      });
    } else {
      this.setState({
        gameState: this.state.gameState.update({ selectedCell: undefined }),
      });
    }
  }

  setupSocket({ gameId, gameAuthToken, userId }) {
    const socket = connectSocket(gameAuthToken);
    const channel = socket.channel(`game:${gameId}:${userId}`, { token: gameAuthToken });
    this.channel = channel;

    channel.join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp, channel);
        channel.push("full_state", { token: gameAuthToken }).receive("ok", (payload) => {
          const { cells, rows, columns, mountains } = payload.board;
          const { turn } = payload;

          console.log(payload);
          this.handleFullBoardEvent({ rows, columns, turn, cells, mountains });
        });
      })
      .receive("error", resp => {
        console.log("Unable to join", resp);
      });
    channel.onError(() => console.log("there was an error!"))
    channel.onClose(() => console.log("The channel closed"));
    channel.on("tick", (payload) => {
      this.handleTickEvent(payload);
    });
  }

  handleFullBoardEvent({ cells, columns, rows, turn, mountains }) {
    let nextState = this.state.gameState.update({ cells: makeCellsVisible(cells), columns, rows, currentTurn: turn, initialized: true });
    nextState = nextState.update({ cells: removeCellVisible(mountains) });
    this.setState({ gameState: nextState });
  }

  handleTickEvent({ turn, changes }) {
    let nextState = this.state.gameState.update({ currentTurn: turn, cells: makeCellsVisible(changes) });
    this.setState({ gameState: nextState });
  };
}

function makeCellsVisible(cells) {
  return cells.map((cell) => {
    cell.visible = true;
    return cell;
  });
}

function removeCellVisible(cells) {
  return cells.map((cell) => {
    delete cell.visible;
    return cell;
  });
}
