defmodule FootballSeasons.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :division, :string
      add :season, :string
      add :date, :date
      add :home_team_id, :integer
      add :away_team_id, :integer
      add :fthg, :integer
      add :ftag, :integer
      add :hthg, :integer
      add :htag, :integer

      timestamps()
    end

    create index(:games, [:division], using: "HASH")
    create index(:games, [:season], using: "HASH")
    create index(:games, [:home_team_id])
    create index(:games, [:away_team_id])
  end
end
