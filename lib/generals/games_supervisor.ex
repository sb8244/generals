defmodule Generals.GamesSupervisor do
  use Supervisor

  def get_game(id, opts \\ []) do
    options = Keyword.merge([name: __MODULE__], opts)
    Supervisor.start_child(options[:name], [%{game_id: id, board: opts[:board]}]) |> case do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def start_link(opts \\ []) do
    options = Keyword.merge([name: __MODULE__], opts)
    Supervisor.start_link(__MODULE__, [], name: options[:name])
  end

  def init([]) do
    children = [
      supervisor(Generals.Game.Supervisor, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
