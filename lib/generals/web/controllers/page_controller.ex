defmodule Generals.Web.PageController do
  use Generals.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
