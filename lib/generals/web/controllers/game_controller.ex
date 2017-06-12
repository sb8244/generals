defmodule Generals.Web.GameController do
  use Generals.Web, :controller

  def index(conn, _params) do
    ensure_user_id(conn)
      |> render("index.html")
  end

  def create(conn, _params) do
    conn = ensure_user_id(conn)
    case Generals.GamesSupervisor.create_game(user_ids: [get_user_id(conn)]) do
      {:ok, id, _pid} -> redirect(conn, to: game_path(conn, :show, id))
    end
  end

  def show(conn, %{"id" => id}) do
    conn = ensure_user_id(conn)
    case Generals.GamesSupervisor.get_game(id) do
      pid when is_pid(pid) -> text(conn, inspect({id, get_session(conn, :user_id)}))
      nil -> text(conn, "This is not a game")
    end
  end

  defp ensure_user_id(conn) do
    case get_user_id(conn) do
      nil -> put_session(conn, :user_id, UUID.uuid4())
      _ -> conn
    end
  end

  defp get_user_id(conn) do
    get_session(conn, :user_id)
  end
end
