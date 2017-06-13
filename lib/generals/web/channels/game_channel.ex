defmodule Generals.Web.GameChannel do
  use Phoenix.Channel

  def join("game:" <> game_id, %{"token" => token}, socket) do
    Phoenix.Token.verify(Generals.Web.Endpoint, "game.permission", token)
      |> case do
        {:ok, %{game_id: authorized_game_id}} ->
          cond do
            authorized_game_id == game_id -> {:ok, socket}
            true -> {:error, %{reason: "unauthorized"}}
          end
        {:error, _} -> {:error, %{reason: "unauthorized"}}
      end
  end

  def handle_in("full_state", %{"token" => token}, socket = %{topic: "game:" <> game_id}) do
    user_id = socket.assigns.user_id
    case Generals.Game.find_user_game(game_id: game_id, user_id: user_id) do
      {:ok, game_pid} ->
        serialized = Generals.Game.Supervisor.serialize_game(game_pid, user: user_id)
        {:reply, {:ok, serialized}, socket}
      {:error, _} ->
        {:stop, :shutdown, {:error, %{}}, socket}
    end
  end
end
