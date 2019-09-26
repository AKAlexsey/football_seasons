defmodule FootballSeasons.Caching.SearchGameService do
  @moduledoc """
  Contains functions for querying records from mnesia database
  """

  @protobuf "protobuf"
  @json "json"

  alias FootballSeasons.Caching.Game

  @doc """
  Return all games in Game mnesia table
  """
  @spec all_games(binary) :: binary | list
  def all_games(encoding) do
    perform_searching([], encoding)
  end

  defp perform_searching(search_clause, encoding) do
    search_clause
    |> select_query_function(encoding)
    |> Memento.transaction()
    |> normalize_response(encoding)
  end

  defp select_query_function(select_clause, encoding) do
    fn ->
      :mnesia.select(
        Game,
        [{match_spec(), select_clause, select_fields(encoding)}]
      )
    end
  end

  defp normalize_response({:ok, games}, @protobuf) do
    games
    |> Enum.join(<<>>)
    |> to_string()
  end

  defp normalize_response({:ok, games}, _) do
    games
    |> Enum.join(", ")
    |> (fn games -> "[#{games}]" end).()
  end

  @doc """
  Request games by given division and/or season
  """
  @spec search_games({binary | nil, binary | nil, binary}) :: binary | list
  def search_games({nil, nil, @protobuf}), do: <<>>
  def search_games({nil, nil, _encoding}), do: []

  def search_games({division, nil, encoding}) do
    perform_searching([{:==, :"$2", division}], encoding)
  end

  def search_games({nil, season, encoding}) do
    perform_searching([{:==, :"$3", season}], encoding)
  end

  def search_games({division, season, encoding}) do
    perform_searching([{:==, :"$4", Game.make_division_and_season(division, season)}], encoding)
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
      :"$14",
      :"$15"
    }
  end

  defp select_fields(@protobuf), do: [:"$15"]
  defp select_fields(_), do: [:"$14"]
end
