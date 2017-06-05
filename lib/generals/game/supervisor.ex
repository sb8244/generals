defmodule Generals.Game.Supervisor do
  use Supervisor

  alias Generals.Board
  alias Generals.Game

  def start_link(%{game_id: id, board: board = %Board{}}) do
    Supervisor.start_link(__MODULE__, [board: board], name: {:via, Registry, {get_registry_name(), id}})
  end

  def get_board_pid(sup_pid), do: find_child_type(sup_pid, Board.GenServer)
  def tick(sup_pid) do
    IO.inspect {sup_pid, :tick}
  end

  def init([board: board]) do
    tick_fn = fn() -> tick(self()) end
    children = [
      worker(Board.GenServer, [board], restart: :transient),
      worker(Game.TickServer, [%{ticker: tick_fn}], restart: :transient),
    ]

    supervise(children, strategy: :one_for_one)
  end

  def get_registry_name() do
    Game.SupervisorRegistry
  end

  defp find_child_type(sup_pid, type) do
    Enum.find(Supervisor.which_children(sup_pid), {nil, nil, nil, nil}, fn({mod, _pid, _type, _}) ->
      mod == type
    end) |> elem(1)
  end
end
