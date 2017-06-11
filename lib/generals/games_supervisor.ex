defmodule Generals.GamesSupervisor do
  use Supervisor

  @doc """
  Starts a game with a given ID. A game requires a `board` and `user_ids` to start.
  If the given ID is already taken, an error will be returned
  """
  def start_game(id, opts \\ []) do
    options = Keyword.merge([name: __MODULE__], opts)
    game_params = %{game_id: id, board: Keyword.fetch!(options, :board), user_ids: Keyword.fetch!(options, :user_ids)}
    Supervisor.start_child(options[:name], [game_params]) |> case do
      {:ok, pid} -> pid
      {:error, {:already_started, _}} -> {:error, "Game with this ID already exists"}
    end
  end

  @doc """
  Retrieves the game with a given ID. When using this method, ensure that the user has access to the game
  before returning it to them, or they can access games they shouldn't be able to.
  """
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
