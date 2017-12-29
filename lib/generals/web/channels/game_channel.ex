defmodule Generals.Web.GameChannel do
  use Phoenix.Channel

  def join("game:" <> game_and_user_id, %{"token" => token}, socket) do
    [game_id, user_id] = String.split(game_and_user_id, ":")

    Phoenix.Token.verify(Generals.Web.Endpoint, "game.permission", token)
      |> case do
        {:ok, %{user_id: authorized_user_id, game_id: authorized_game_id}} ->
          cond do
            authorized_game_id == game_id && user_id == authorized_user_id -> {:ok, socket}
            true -> {:error, %{reason: "unauthorized"}}
          end
        {:error, _} -> {:error, %{reason: "unauthorized"}}
      end
  end

  def handle_in("full_state", _p, socket = %{topic: "game:" <> _, assigns: %{game_id: game_id, user_id: user_id}}) do
    case Generals.Game.find_user_game(game_id: game_id, user_id: user_id) do
      {:ok, game_pid} ->
        serialized = Generals.Game.Supervisor.serialize_game(game_pid, user: user_id)
        {:reply, {:ok, serialized}, socket}
      {:error, _} ->
        {:stop, :shutdown, {:error, %{}}, socket}
    end
  end

  def handle_in("queue_move", %{"from" => from, "to" => to}, socket = %{topic: "game:" <> _, assigns: %{game_id: game_id, user_id: user_id}}) do
    case Generals.Game.find_user_game(game_id: game_id, user_id: user_id) do
      {:ok, game_pid} ->
        from_coords = {from["row"], from["column"]}
        to_coords = {to["row"], to["column"]}

        case Generals.Game.Supervisor.queue_move(game_pid, user: user_id, from: from_coords, to: to_coords) do
          :ok ->
            {:reply, {:ok, %{action: "queue_move"}}, socket}
          {:error, why} ->
            {:reply, {:error, %{error: why}}, socket}
        end
      {:error, _} ->
        {:stop, :shutdown, {:error, %{}}, socket}
    end
  end

  def handle_in("queue_clear", _params, socket = %{topic: "game:" <> _, assigns: %{game_id: game_id, user_id: user_id}}) do
    case Generals.Game.find_user_game(game_id: game_id, user_id: user_id) do
      {:ok, game_pid} ->
        case Generals.Game.Supervisor.clear_future_moves(game_pid, user: user_id) do
          :ok ->
            {:reply, {:ok, %{action: "queue_clear"}}, socket}
          {:error, why} ->
            {:reply, {:error, %{error: why}}, socket}
        end
      {:error, _} ->
        {:stop, :shutdown, {:error, %{}}, socket}
    end
  end
end
