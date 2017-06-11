defmodule Generals.Game.Supervisor do
  use Supervisor

  alias Generals.Game
  alias Generals.CommandQueue.Command

  @doc """
  Queues a move for the given player from {r,c} to {r,c}. The player must own the
  from coordinates at the time of move creation, or an error will occur.
  """
  def queue_move(sup_pid, player: player, from: from, to: to) do
    %{board: board, turn: turn} = get_board_pid(sup_pid)
      |> Game.BoardServer.get

    case Command.get_move_command(player: player, from: from, to: to, board: board) do
      command = %Command{} ->
        get_command_queue_pid(sup_pid)
          |> Game.CommandQueueServer.add_command(turn + 1, command)
      err -> err
    end
  end

  @doc """
  Clears out all moves from next turn and on for a given player in a game. The next turn
  is used because the current turn moves have already executed.
  """
  def clear_future_moves(sup_pid, player: player) do
    %{turn: turn} = get_board_pid(sup_pid)
      |> Game.BoardServer.get
    get_command_queue_pid(sup_pid)
      |> Game.CommandQueueServer.clear_player_commands(turn + 1, player: player)
  end

  def start_link(opts = %{game_id: id}) do
    Supervisor.start_link(__MODULE__, Map.drop(opts, [:game_id]), name: {:via, Registry, {get_registry_name(), id}})
  end

  def init(opts = %{board: board, user_ids: user_ids}) do
    this = self()
    tick_fn = fn() -> tick(this) end

    children = [
      worker(Game.BoardServer, [board], restart: :transient),
      worker(Game.CommandQueueServer, [], restart: :transient),
      worker(Game.PlayerServer, [[user_ids: user_ids]], restart: :transient),
      worker(Game.TickServer, [%{ticker: tick_fn, timeout: Map.get(opts, :timeout, 1000)}], restart: :transient),
    ]

    supervise(children, strategy: :one_for_one)
  end

  def get_registry_name() do
    Game.SupervisorRegistry
  end

  def get_board_pid(sup_pid), do: find_child_type(sup_pid, Game.BoardServer)
  def get_command_queue_pid(sup_pid), do: find_child_type(sup_pid, Game.CommandQueueServer)

  defp tick(sup_pid) do
    board_pid = get_board_pid(sup_pid)
    queue_pid = get_command_queue_pid(sup_pid)

    %{turn: turn} = Game.BoardServer.tick(board_pid)
    Game.CommandQueueServer.commands_for_turn(queue_pid, turn)
      |> Enum.each(fn(command) ->
        Game.BoardServer.execute_command(board_pid, command)
      end)
  end

  defp find_child_type(sup_pid, type) do
    Enum.find(Supervisor.which_children(sup_pid), {nil, nil, nil, nil}, fn({mod, _pid, _type, _}) ->
      mod == type
    end) |> elem(1)
  end
end
