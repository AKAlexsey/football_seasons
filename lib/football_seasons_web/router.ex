defmodule FootballSeasonsWeb.Router do
  use FootballSeasonsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug FootballSeasons.Authorization.Pipeline
    plug FootballSeasons.Authorization.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :with_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  scope "/", FootballSeasonsWeb do
    pipe_through [:browser]

    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    get "/", PageController, :index
  end

  scope "/", FootballSeasonsWeb do
    pipe_through [:browser, :with_session]

    resources "/games", GameController
    resources "/teams", TeamController
    resources "/users", UserController
    resources "/files", FileController, only: [:new, :create]
  end
end
