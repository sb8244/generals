defmodule Generals.Web.Router do
  use Generals.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Generals.Web do
    pipe_through :browser # Use the default browser stack

    get "/", GameController, :index
    resources "/games", GameController, only: [:index, :show, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Generals.Web do
  #   pipe_through :api
  # end
end
