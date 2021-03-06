import { h, render } from 'preact';

import Game from './ui/Game';

const boardContainer = document.getElementById('board-container');

if (boardContainer) {
  render((
    <Game gameId={window.gameId} gameAuthToken={window.gameAuthToken} userId={window.userId} />
  ), boardContainer);
}
