defmodule Generals.Game.Supervisor do
  use Supervisor

  alias Generals.Game
  alias Generals.CommandQueue.Command

  def player_has_access?(sup_pid, user_id) do
    case user_id_to_player_id(sup_pid, user_id) do
      {:error, _} -> false
      _ -> true
    end
  end

  @doc """
  Queues a move for the given user from {r,c} to {r,c}. The player must own the
  from coordinates at the time of move creation, or an error will occur.
  """
  def queue_move(sup_pid, user: user_id, from: from, to: to) do
    case user_id_to_player_id(sup_pid, user_id) do
      err = {:error, _} -> err
      player ->
        %{board: board, turn: turn} = get_board_pid(sup_pid)
          |> Game.BoardServer.get

        case Command.get_move_command(player: player, from: from, to: to, board: board) do
          command = %Command{} ->
            get_command_queue_pid(sup_pid)
              |> Game.CommandQueueServer.add_command(turn + 1, command)
          err -> err
        end
    end
  end

  @doc """
  Clears out all moves from next turn and on for a given user in a game. The next turn
  is used because the current turn moves have already executed.
  """
  def clear_future_moves(sup_pid, user: user_id) do
    case user_id_to_player_id(sup_pid, user_id) do
      err = {:error, _} -> err
      player ->
        %{turn: turn} = get_board_pid(sup_pid)
          |> Game.BoardServer.get
        get_command_queue_pid(sup_pid)
          |> Game.CommandQueueServer.clear_player_commands(turn + 1, player: player)
    end
  end

  def serialize_game(sup_pid, user: user_id) do
    case user_id_to_player_id(sup_pid, user_id) do
      err = {:error, _} -> err
      player ->
        board_server = get_board_pid(sup_pid)
        %{board: board, turn: turn} = Game.BoardServer.get(board_server)
        player_server = get_player_server_pid(sup_pid)
        %{
          board: Generals.Board.BoardSerializer.for_player(board, player: player),
          players: Game.PlayerServer.get_players(player_server),
          turn: turn
        }
    end
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
  def get_player_server_pid(sup_pid), do: find_child_type(sup_pid, Game.PlayerServer)
  def get_tick_server_pid(sup_pid), do: find_child_type(sup_pid, Game.TickServer)

  defp tick(sup_pid) do
    board_pid = get_board_pid(sup_pid)
    queue_pid = get_command_queue_pid(sup_pid)

    %{turn: turn, changed_coords: coords} = Game.BoardServer.tick(board_pid)
    Game.CommandQueueServer.commands_for_turn(queue_pid, turn)
      |> Enum.flat_map(fn(command) ->
        case Game.BoardServer.execute_command(board_pid, command) do
          {:ok, _} -> [command.from, command.to]
          _ -> []
        end
      end)
      |> Enum.concat(coords)
      |> Enum.uniq
      |> IO.inspect
  end

  defp find_child_type(sup_pid, type) do
    Enum.find(Supervisor.which_children(sup_pid), {nil, nil, nil, nil}, fn({mod, _pid, _type, _}) ->
      mod == type
    end) |> elem(1)
  end

  defp user_id_to_player_id(sup_pid, user_id) do
    get_player_server_pid(sup_pid)
      |> Game.PlayerServer.get_active_player_id(user_id)
      |> case do
        nil -> {:error, "You are not in this game"}
        player -> player
      end
  end
end
