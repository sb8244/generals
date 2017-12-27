import { h, render } from 'preact';

import Board from './ui/board';
import GameComm from './ui/game_comm';

const boardContainer = document.getElementById('board-container');

if (boardContainer) {
  render((
    <GameComm gameId={window.gameId} gameAuthToken={window.gameAuthToken} userId={window.userId}>
      <Board />
    </GameComm>
  ), boardContainer);
}
