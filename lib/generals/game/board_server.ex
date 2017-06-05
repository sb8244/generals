defmodule Generals.Game.BoardServer do
  def start_link(board) do
    GenServer.start_link(__MODULE__, [board: board])
  end

  def init([board: board]) do
    {:ok, %{board: board, turn: 0 }}
  end

  def get_board(pid) do
    GenServer.call(pid, :get_board)
  end

  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  def handle_call(:get_board, _from, state = %{board: board}) do
    {:reply, board, state}
  end

  def handle_call(:tick, _from, %{board: board, turn: turn}) do
    next_state = %{
      turn: turn + 1,
      board: Generals.Board.tick(board, turn + 1)
    }

    {:reply, next_state, next_state}
  end
end
