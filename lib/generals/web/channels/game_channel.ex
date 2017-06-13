defmodule Generals.Web.GameChannel do
  use Phoenix.Channel

  def join("game:" <> _private_room_id, %{"token" => token}, socket) do
    Phoenix.Token.verify(Generals.Web.Endpoint, "game.permission", token)
      |> case do
        {:ok, _} -> {:ok, socket}
        {:error, _} -> {:error, %{reason: "unauthorized"}}
      end
  end

  def handle_in("full_state", %{"token" => token}, socket = %{topic: "game:" <> game_id}) do
    case Phoenix.Token.verify(Generals.Web.Endpoint, "game.permission", token) do
      {:ok, %{user_id: user_id}} ->
        case Generals.Game.find_user_game(game_id: game_id, user_id: user_id) do
          {:ok, game_pid} ->
            serialized = Generals.Game.Supervisor.serialize_game(game_pid, user: user_id)
            {:reply, {:ok, serialized}, socket}
          {:error, _} ->
            {:stop, :shutdown, {:error, %{}}, socket}
        end
      {:error, _} -> {:stop, :shutdown, {:error, %{}}, socket}
    end
  end
end
