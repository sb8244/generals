defmodule Generals.Game.BoardServer do
  alias Generals.CommandQueue.Command

  def start_link(board) do
    GenServer.start_link(__MODULE__, [board: board])
  end

  def init([board: board]) do
    {:ok, %{board: board, turn: 0}}
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def get_board(pid) do
    GenServer.call(pid, :get_board)
  end

  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  def execute_command(pid, command = %Command{}) do
    GenServer.call(pid, {:execute_command, command})
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
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

  def handle_call({:execute_command, command}, _from, %{board: board, turn: turn}) do
    {status, next_board} = case Command.execute(command, board) do
      {:ok, next_board} -> {:ok, next_board}
      {:error, _} -> {:invalid, board}
    end

    next_state = %{
      turn: turn,
      board: next_board
    }

    {:reply, {status, next_state}, next_state}
  end
end
