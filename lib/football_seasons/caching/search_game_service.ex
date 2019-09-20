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
    games
    |> Enum.join(", ")
    |> (fn games -> "[#{games}]" end).()
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
      :_,
      :_,
      :_,
      :_,
      :_,
      :_,
      :_,
      :_,
      :_,
      :"$14"
    }
  end

  defp select_fields, do: [:"$14"]
end
