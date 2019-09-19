defmodule FootballSeasonsWeb.Router do
  use FootballSeasonsWeb, :router

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

  scope "/", FootballSeasonsWeb do
    pipe_through :browser

    resources "/games", GameController
    resources "/teams", TeamController
    resources "/users", UserController
    resources "/files", FileController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    get "/", PageController, :index
  end
end
