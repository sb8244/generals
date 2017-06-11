defmodule Generals.GamesSupervisor do
  use Supervisor

  def start_game(id, opts \\ []) do
    options = Keyword.merge([name: __MODULE__], opts)
    game_params = %{game_id: id, board: options[:board], user_ids: options[:user_ids]}
    Supervisor.start_child(options[:name], [game_params]) |> case do
      {:ok, pid} -> pid
      {:error, {:already_started, _}} -> {:error, "Game with this ID already exists"}
    end
  end

  def get_game(id, opts \\ []) do
    options = Keyword.merge([name: __MODULE__], opts)
    Supervisor.start_child(options[:name], [%{game_id: id}]) |> case do
      {:error, {:already_started, pid}} -> pid
      {:error, _} -> nil
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
