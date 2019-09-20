defmodule FootballSeasons.Caching.CacheRecordService do
  @moduledoc """
  Request 'games' with preloaded 'teams' and pass them to MnesiaRecordHandler
  """

  alias FootballSeasons.Caching.MnesiaRecordHandler
  alias FootballSeasons.Seasons

  def perform do
    [:home_team, :away_team]
    |> Seasons.list_games()
    |> Enum.map(fn game ->
      MnesiaRecordHandler.perform(:cache, game)
    end)
  end
end
