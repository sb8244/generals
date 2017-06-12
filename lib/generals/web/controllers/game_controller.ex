defmodule Generals.Web.GameController do
  use Generals.Web, :controller

  plug :ensure_user_id

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, _params) do
    case Generals.Game.create_game(get_user_id(conn)) do
      {:ok, id, _pid} -> redirect(conn, to: game_path(conn, :show, id))
    end
  end

  def show(conn, %{"id" => id}) do
    case Generals.Game.find_user_game(game_id: id, user_id: get_user_id(conn)) do
      {:ok, _} -> text(conn, inspect({id, get_session(conn, :user_id)}))
      {:error, why} -> text(conn, why)
    end
  end

  defp ensure_user_id(conn, _p) do
    case get_user_id(conn) do
      nil -> put_session(conn, :user_id, UUID.uuid4())
      _ -> conn
    end
  end

  defp get_user_id(conn) do
    get_session(conn, :user_id)
  end
end
