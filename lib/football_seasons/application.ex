defmodule FootballSeasons.Application do
  @moduledoc false

  use Application

  alias FootballSeasons.{BackgroundJobsWorker, Repo}
  alias FootballSeasonsWeb.{ApiRouter, Endpoint}
  alias Plug.Cowboy

  def start(_type, _args) do
    children = [
      BackgroundJobsWorker,
      Cowboy.child_spec(
        scheme: :http,
        plug: ApiRouter,
        options: [port: Application.get_env(:football_seasons, :plug_configuration)[:api_port]]
      ),
      Endpoint,
      Repo
    ]

    opts = [strategy: :one_for_one, name: FootballSeasons.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    FootballSeasonsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
