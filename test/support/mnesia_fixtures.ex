defmodule FootballSeasons.MnesiaFixtures do
  @moduledoc """
  Simplify writing Mnesia tests with Mnesia.
  """

  alias FootballSeasons.Caching.Game
  alias FootballSeasons.Seasons.PeriodResult

  @random_seed 5

  @doc """
  Insert game into mnesia. Return transaction result.
  """
  @spec insert_mnesia(atom, map) :: {:ok, map()}
  def insert_mnesia(:game, params \\ %{}) do
    Memento.transaction(fn ->
      default_game_params()
      |> Map.merge(params)
      |> Map.merge(%Game{})
      |> Memento.Query.write()
    end)
  end

  defp default_game_params do
    division = Faker.Lorem.word()
    season = Enum.random(["201718", "201819", "201920"])
    htag = random_generator()
    hthg = random_generator()
    ftag = htag + random_generator()
    fthg = hthg + random_generator()

    %{
      id: :rand.uniform(99_999),
      division: division,
      season: season,
      division_and_season: Game.make_division_and_season(division, season),
      date: to_string(Date.utc_today()),
      home_team_name: Faker.Lorem.word(),
      away_team_name: Faker.Lorem.word(),
      htag: htag,
      hthg: hthg,
      htr: PeriodResult.get_htr(%{htag: htag, hthg: hthg}),
      ftag: ftag,
      fthg: fthg,
      ftr: PeriodResult.get_ftr(%{ftag: ftag, fthg: fthg})
    }
  end

  defp random_generator, do: :rand.uniform(@random_seed)

  @doc """
  Request record of given type inside memento transaction
  """
  @spec read_mnesia(atom, integer) :: {:ok, term}
  def read_mnesia(:game, game_id) do
    Memento.transaction(fn ->
      Memento.Query.read(Game, game_id)
    end)
  end
end
