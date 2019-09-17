defmodule FootballSeasons.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      FootballSeasons.Repo,
      FootballSeasonsWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: FootballSeasons.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    FootballSeasonsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
