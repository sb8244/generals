import { h, Component } from 'preact';

import connectSocket from '../socket';
import GameState from '../game/state';

import Board from './Board';
import GameScroll from './GameScroll';

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
    this.setSelectedCoords = this.setSelectedCoords.bind(this);
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
        <Board gameState={gameState} position={boardPosition} setSelectedCoords={this.setSelectedCoords} />
      </div>
    )
  }

  setSelectedCoords(coords) {
    this.setState({
      gameState: this.state.gameState.update({ selectedCoords: coords }),
    });
  }

  setupSocket({ gameId, gameAuthToken, userId }) {
    const socket = connectSocket(gameAuthToken);
    const channel = socket.channel(`game:${gameId}:${userId}`, { token: gameAuthToken });
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
    nextState = nextState.update({ cells: mountains });
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
