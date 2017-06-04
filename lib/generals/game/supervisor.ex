defmodule Generals.Game.Supervisor do
  use Supervisor

  alias Generals.Board

  def start_link(%{game_id: id}) do
    Supervisor.start_link(__MODULE__, [id: id], name: {:via, Registry, {get_registry_name(), id}})
  end

  def init([id: id]) do
    children = [
      #worker(Board.GenServer, [], restart: :transient)
    ]

    supervise(children, strategy: :one_for_one)
  end

  def get_registry_name() do
    Generals.Game.SupervisorRegistry
  end
end
