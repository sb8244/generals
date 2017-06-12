defmodule Generals.Web.GameChannel do
  use Phoenix.Channel

  def join("game:" <> _private_room_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("full_state", _params, socket) do
    "game:" <> game_id = socket.topic
    broadcast!(socket, "full_state", %{id: game_id})
    {:noreply, socket}
  end
end
