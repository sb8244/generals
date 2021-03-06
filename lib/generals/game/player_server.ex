defmodule Generals.Game.PlayerServer do
  def start_link(opts) do
    Agent.start_link(fn -> map_user_ids_to_players(opts[:user_ids]) end)
  end

  @doc """
    Return the user ids in the game
  """
  def get_players(pid) do
    Agent.get(pid, fn(state) ->
      Map.keys(state)
    end)
  end

  @doc """
    Return the full mapping for the game

    %{user_id => %{player_id:, left:}}
  """
  def get_players_mapping(pid) do
    Agent.get(pid, fn(state) ->
      state
    end)
  end

  @doc """
    Return the player id for a user, if the user has not left the game
  """
  def get_active_player_id(pid, user_id) do
    Agent.get(pid, fn(state) ->
      case Map.get(state, user_id) do
        nil -> nil
        %{left: true} -> nil
        %{player_id: player_id, left: false} -> player_id
      end
    end)
  end

  @doc """
    Mark a given user as having left a game
  """
  def user_left(pid, user_id) do
    Agent.get_and_update(pid, fn(state) ->
      Map.get_and_update(state, user_id, fn(player_map) ->
        case player_map do
          nil -> :pop
          player_map -> {player_map, Map.put(player_map, :left, true)}
        end
      end)
    end)
      |> case do
        nil -> false
        _ -> true
      end
  end

  defp map_user_ids_to_players(user_ids) do
    Enum.shuffle(user_ids)
      |> Enum.with_index
      |> Enum.map(fn({user_id, player_id}) ->
        {
          user_id,
          %{
            player_id: player_id,
            left: false,
          }
        }
      end)
      |> Enum.into(%{})
  end
end
