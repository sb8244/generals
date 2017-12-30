defmodule Generals.Web.GameSocket do
  use Phoenix.Socket

  ## Channels
  channel "game:*", Generals.Web.GameChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket) do
    Phoenix.Token.verify(Generals.Web.Endpoint, "game.permission", token)
      |> case do
        {:ok, %{user_id: user_id, game_id: game_id}} ->
          socket = socket
            |> assign(:user_id, user_id)
            |> assign(:game_id, game_id)
          {:ok, socket}
        {:error, _} -> {:error, %{reason: "unauthorized"}}
      end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Generals.Web.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "game_socket:#{socket.assigns.game_id}:#{socket.assigns.user_id}"
end
