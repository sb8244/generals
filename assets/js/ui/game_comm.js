import { h, cloneElement, Component } from 'preact';

import connectSocket from '../socket';
import GameState from '../game/state';

export default class GameComm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      gameState: new GameState({}),
    };

    this.setupSocket(props);
  }

  render() {
    const { children } = this.props;
    const { gameState } = this.state;

    return cloneElement(children[0], { gameState });
  }

  setupSocket({ gameId, gameAuthToken, userId }) {
    const socket = connectSocket(gameAuthToken);
    const channel = socket.channel(`game:${gameId}:${userId}`, { token: gameAuthToken });
    channel.join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp, channel);
        channel.push("full_state", { token: gameAuthToken }).receive("ok", (payload) => {
          const { cells, rows, columns } = payload.board;
          const { turn } = payload;

          this.handleFullBoardEvent({ rows, columns, turn, cells });
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

  handleFullBoardEvent({ cells, columns, rows, turn }) {
    const nextState = this.state.gameState.update({ cells, columns, rows, currentTurn: turn, initialized: true });
    this.setState({ gameState: nextState });
  }

  handleTickEvent({ turn, changes }) {
    let nextState = this.state.gameState.update({ currentTurn: turn, cells: changes });
    this.setState({ gameState: nextState });
  };
}
