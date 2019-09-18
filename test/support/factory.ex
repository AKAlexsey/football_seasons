defmodule FootballSeasons.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: FootballSeasons.Repo

  alias FootballSeasons.Seasons.{Game, Team}

  def game_factory(attrs) do
    %Game{
      division: "SP1",
      season: "201920",
      date: sequence(:date, fn n -> Date.add(Date.utc_today(), n) end),
      fthg: 5,
      ftag: 3,
      hthg: 2,
      htag: 3
    }
    |> Map.merge(attrs)
    |> build_team_if_necessary(:home_team_id)
    |> build_team_if_necessary(:away_team_id)
  end

  defp build_team_if_necessary(record, attribute_name) do
    case Map.get(record, attribute_name, nil) do
      nil ->
        %{id: team_id} = insert(:team)
        Map.put(record, attribute_name, team_id)

      _ ->
        record
    end
  end

  def team_factory(attrs) do
    %Team{
      name: sequence(:name, &"Team name ##{&1}")
    }
    |> Map.merge(attrs)
  end
end
