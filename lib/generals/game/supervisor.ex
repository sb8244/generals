defmodule Generals.Game.Supervisor do
  use Supervisor

  alias Generals.Board
  alias Generals.Game

  def start_link(opts = %{game_id: id}) do
    Supervisor.start_link(__MODULE__, Map.drop(opts, [:game_id]), name: {:via, Registry, {get_registry_name(), id}})
  end

  def get_board_pid(sup_pid), do: find_child_type(sup_pid, Board.GenServer)

  def init(opts = %{board: board}) do
    this = self()
    tick_fn = fn() -> tick(this) end

    children = [
      worker(Board.GenServer, [board], restart: :transient),
      worker(Game.TickServer, [%{ticker: tick_fn, timeout: Map.get(opts, :timeout, 1000)}], restart: :transient),
    ]

    supervise(children, strategy: :one_for_one)
  end

  def get_registry_name() do
    Game.SupervisorRegistry
  end

  defp tick(sup_pid) do
    get_board_pid(sup_pid)
      |> Board.GenServer.tick
  end

  defp find_child_type(sup_pid, type) do
    Enum.find(Supervisor.which_children(sup_pid), {nil, nil, nil, nil}, fn({mod, _pid, _type, _}) ->
      mod == type
    end) |> elem(1)
  end
end
