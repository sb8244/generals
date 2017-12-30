defmodule Generals.Game.BoardServer do
  alias Generals.CommandQueue.Command

  def start_link(board) do
    GenServer.start_link(__MODULE__, [board: board])
  end

  def init([board: board]) do
    {:ok, %{board: board, turn: 0}}
  end

  @doc """
    Returns the state of the board server

    %{board:, turn:}
  """
  def get(pid) do
    GenServer.call(pid, :get)
  end

  @doc """
    Return the board from state
  """
  def get_board(pid) do
    GenServer.call(pid, :get_board)
  end

  def set_board_for_testing(pid, board) do
    GenServer.call(pid, {:set_board, board})
  end

  @doc """
    Ticks the board forward 1 turn and maintains new state

    %{board:, turn:, changed_coords: [{r, c}]}
  """
  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  @doc """
    Execute a Command on the board

    {:ok, next_state} | {:invalid, next_state}
  """
  def execute_command(pid, command = %Command{}) do
    GenServer.call(pid, {:execute_command, command})
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_board, _from, state = %{board: board}) do
    {:reply, board, state}
  end

  def handle_call({:set_board, board}, _from, state) do
    {:reply, board, Map.put(state, :board, board)}
  end

  def handle_call(:tick, _from, %{board: board, turn: turn}) do
    %{board: next_board, changed_coords: coords} = Generals.Board.tick(board, turn + 1)
    next_state = %{
      turn: turn + 1,
      board: next_board
    }

    {:reply, Map.put(next_state, :changed_coords, coords), next_state}
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
