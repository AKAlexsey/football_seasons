defmodule FootballSeasons.Repo do
  use Ecto.Repo,
    otp_app: :football_seasons,
    adapter: Ecto.Adapters.Postgres

  use Observable.Repo
end
