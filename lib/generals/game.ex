defmodule Generals.Game do
  @not_a_game "This is not a game"

  def create_game(user_id) do
    Generals.GamesSupervisor.create_game(user_ids: [user_id])
  end

  def find_user_game(game_id: id, user_id: user) do
    case Generals.GamesSupervisor.get_game(id) do
      pid when is_pid(pid) ->
        case Generals.Game.Supervisor.player_has_access?(pid, user) do
          true -> {:ok, pid}
          false -> {:error, @not_a_game}
        end
      nil -> {:error, @not_a_game}
    end
  end
end
