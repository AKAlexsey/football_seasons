defmodule FootballSeasons.Caching.SearchGameService do
  @moduledoc """
  Contains functions for querying records from mnesia database
  """

  alias FootballSeasons.Caching.Game

  @doc """
  Return all games in Game mnesia table
  """
  def all_games(pagination_params \\ %{}) do
    perform_searching([])
  end

  defp perform_searching(search_clause) do
    search_clause
    |> select_query_function()
    |> Memento.transaction()
    |> normalize_response()
  end

  defp select_query_function(select_clause) do
    fn ->
      :mnesia.select(
        Game,
        [{match_spec(), select_clause, select_fields()}]
      )
    end
  end

  defp normalize_response({:ok, games}) do
    Enum.map(games, &make_map/1)
  end

  @doc """
  Request games by given division and/or season
  """
  def search_games({nil, nil}), do: []

  def search_games({division, nil}) do
    perform_searching([{:==, :"$2", division}])
  end

  def search_games({nil, season}) do
    perform_searching([{:==, :"$3", season}])
  end

  def search_games({division, season}) do
    perform_searching([{:==, :"$4", Game.make_division_and_season(division, season)}])
  end

  defp match_spec do
    {
      Game,
      :_,
      :"$2",
      :"$3",
      :"$4",
      :"$5",
      :"$6",
      :"$7",
      :"$8",
      :"$9",
      :"$10",
      :"$11",
      :"$12",
      :"$13"
    }
  end

  defp select_fields, do: [:"$$"]

  defp make_map([
         division,
         season,
         _division_and_season,
         date,
         home_team_name,
         away_team_name,
         hthg,
         htag,
         htr,
         fthg,
         ftag,
         ftr
       ]) do
    %{
      division: division,
      season: season,
      date: date,
      home_team_name: home_team_name,
      away_team_name: away_team_name,
      hthg: hthg,
      htag: htag,
      htr: htr,
      fthg: fthg,
      ftag: ftag,
      ftr: ftr
    }
  end
end
